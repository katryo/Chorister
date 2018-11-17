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
    var response: URLResponse?
    var connections = [String: NSURLConnection]()
    var audioCache: Cache<NSData>
    
    
    init(cache: Cache<NSData>) {
        audioCache = cache
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.songData = NSMutableData()  // Reset the songData
        self.response = response
        self.processPendingRequests()
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        self.songData.append(data as Data)
        self.processPendingRequests()
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        self.processPendingRequests()
        let tmpUrl = NSURL(string: (connection.currentRequest.url?.absoluteString)!)!
        let actualUrl = getActualURL(url: tmpUrl)
        let urlString = actualUrl.absoluteString
        if (audioCache.objectForKey(key: urlString!) != nil) {
            return
        }
        audioCache[urlString!] = songData
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        print(error)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        let url = loadingRequest.request.url!
        let interceptedURL = loadingRequest.request.url!.absoluteString
        let actualURL = getActualURL(url: url as NSURL)
        let urlString = actualURL.absoluteString
        if (connections[urlString!] == nil) {
            let request = NSURLRequest(url: actualURL as URL)
            let connection = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately: false)!
            connection.setDelegateQueue(OperationQueue.main)
            connection.start()
            connections[actualURL.absoluteString!] = connection
        }
        self.pendingRequests.append(loadingRequest)
        return true
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        pendingRequests = pendingRequests.filter({ $0 != loadingRequest })
    }
    
    private func processPendingRequests() {
        var requestsCompleted = [AVAssetResourceLoadingRequest]()
        for loadingRequest in pendingRequests {
            fillInContentInformation(contentInformationRequest: loadingRequest.contentInformationRequest)
            let didRespondCompletely = respondWithDataForRequest(dataRequest: loadingRequest.dataRequest!)
            if didRespondCompletely == true {
                requestsCompleted.append(loadingRequest)
                loadingRequest.finishLoading()
            }
        }
        for requestCompleted in requestsCompleted {
            for (i, pendingRequest) in pendingRequests.enumerated() {
                if requestCompleted == pendingRequest {
                    pendingRequests.remove(at: i)
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
        
        let mimeType = self.response!.mimeType
        let unmanagedContentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, mimeType! as CFString, nil)
        let cfContentType = unmanagedContentType!.takeRetainedValue()
        contentInformationRequest!.contentType = String(cfContentType)
        contentInformationRequest!.isByteRangeAccessSupported = true
        contentInformationRequest!.contentLength = self.response!.expectedContentLength
    }
    
    private func respondWithDataForRequest(dataRequest: AVAssetResourceLoadingDataRequest) -> Bool {
        var startOffset: Int64 = dataRequest.requestedOffset
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
        dataRequest.respond(with: self.songData.subdata(with: NSMakeRange(Int(startOffset), Int(numberOfBytesToRespondWith))))
        let endOffset = startOffset + Int64(dataRequest.requestedLength)
        let didRespondFully = songDataLength >= endOffset
        return didRespondFully
    }
    
    private func getActualURL(url: NSURL) -> NSURL {
        let actualURLComponents = NSURLComponents(url: url as URL, resolvingAgainstBaseURL: false)
        if url.scheme == "httpstreaming" {
            actualURLComponents!.scheme = "http"
        } else if url.scheme == "httpsstreaming" {
            actualURLComponents!.scheme = "https"
        }
        print("actualURLCoponents:" + actualURLComponents!.url!.absoluteString)
        return actualURLComponents!.url! as NSURL
    }
    
}
