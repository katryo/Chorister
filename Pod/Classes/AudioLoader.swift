//
//  AudioLoader.swift
//  Pods
//
//  Created by RYOKATO on 2015/12/05.
//
//

import AVFoundation
import MobileCoreServices

class AudioLoader: NSObject, AVAssetResourceLoaderDelegate, NSURLConnectionDataDelegate {
    var pendingRequests = [AVAssetResourceLoadingRequest]()
    var songData = NSMutableData()
    var response: NSURLResponse?
    var connections = [String: NSURLConnection]()
    var audioCache: Cache<NSData>
    
    
    init(cache: Cache<NSData>) {
        audioCache = cache
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.songData = NSMutableData()  // Reset the songData
        self.response = response
        self.processPendingRequests()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.songData.appendData(data)
        self.processPendingRequests()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.processPendingRequests()
        let url = getActualURL(connection.currentRequest.URL!)
        let urlString = url.absoluteString
        if (audioCache.objectForKey(urlString) != nil) {
            return
        }
        audioCache[urlString] = songData
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        print(error)
    }
    
    func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let interceptedURL = loadingRequest.request.URL
        let actualURL = getActualURL(interceptedURL!)
        let urlString = actualURL.absoluteString
        if (connections[urlString] == nil) {
            let request = NSURLRequest(URL: actualURL)
            let connection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
            connection.setDelegateQueue(NSOperationQueue.mainQueue())
            connection.start()
            connections[actualURL.absoluteString] = connection
        }
        self.pendingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(resourceLoader: AVAssetResourceLoader, didCancelLoadingRequest loadingRequest: AVAssetResourceLoadingRequest) {
        pendingRequests = pendingRequests.filter({ $0 != loadingRequest })
    }
    
    private func processPendingRequests() {
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in pendingRequests {
            fillInContentInformation(loadingRequest.contentInformationRequest)
            let didRespondCompletely = respondWithDataForRequest(loadingRequest.dataRequest!)
            if didRespondCompletely == true {
                requestsCompleted.append(loadingRequest)
                loadingRequest.finishLoading()
            }
        }
        for requestCompleted in requestsCompleted {
            for (i, pendingRequest) in pendingRequests.enumerate() {
                if requestCompleted == pendingRequest {
                    pendingRequests.removeAtIndex(i)
                }
            }
        }
    }
    
    private func fillInContentInformation(contentInformationRequest: AVAssetResourceLoadingContentInformationRequest?) {
        if(contentInformationRequest == nil) {
            return
        }
        if (self.response == nil) {
            return
        }
        
        let mimeType = self.response!.MIMEType
        let unmanagedContentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, mimeType!, nil)
        let cfContentType = unmanagedContentType!.takeRetainedValue()
        contentInformationRequest!.contentType = String(cfContentType)
        contentInformationRequest!.byteRangeAccessSupported = true
        contentInformationRequest!.contentLength = self.response!.expectedContentLength
    }
    
    private func respondWithDataForRequest(dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        var startOffset = dataRequest.requestedOffset
        if dataRequest.currentOffset != 0 {
            startOffset = dataRequest.currentOffset
        }
        let songDataLength = Int64(self.songData.length)
        if songDataLength < startOffset {
            return false
        }
        let unreadBytes = songDataLength - startOffset
        let numberOfBytesToRespondWith: Int64
        if Int64(dataRequest.requestedLength) > unreadBytes {
            numberOfBytesToRespondWith = unreadBytes
        } else {
            numberOfBytesToRespondWith = Int64(dataRequest.requestedLength)
        }
        dataRequest.respondWithData(self.songData.subdataWithRange(NSMakeRange(Int(startOffset), Int(numberOfBytesToRespondWith))))
        let endOffset = startOffset + dataRequest.requestedLength
        let didRespondFully = songDataLength >= endOffset
        return didRespondFully
    }
    
    private func getActualURL(url: NSURL) -> NSURL {
        let actualURLComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        if url.scheme == "httpstreaming" {
            actualURLComponents!.scheme = "http"
        } else if url.scheme == "httpsstreaming" {
            actualURLComponents!.scheme = "https"
        }
        print("actualURLCoponents:" + actualURLComponents!.URL!.absoluteString)
        return actualURLComponents!.URL!
    }
    
}
