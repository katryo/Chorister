# Chorister

[![CI Status](http://img.shields.io/travis/Ryo Kato/Chorister.svg?style=flat)](https://travis-ci.org/Ryo Kato/Chorister)
[![Version](https://img.shields.io/cocoapods/v/Chorister.svg?style=flat)](http://cocoapods.org/pods/Chorister)
[![License](https://img.shields.io/cocoapods/l/Chorister.svg?style=flat)](http://cocoapods.org/pods/Chorister)
[![Platform](https://img.shields.io/cocoapods/p/Chorister.svg?style=flat)](http://cocoapods.org/pods/Chorister)

Christer can play tunes with streaming, store it in the cache and reuse it when it is possible.

This library is created for the Denkinovel app https://itunes.apple.com/jp/app/denkinovel/id1000108250?l=ja&ls=1&mt=8

## Usage

Here is an example to use Chorister.

```
import UIKit
import Chorister

class ViewController: UIViewController {
    var audioContainer = StreamingAudioCacheContainer(repeats: true)

    @IBAction func ButtonAPushed(sender: UIButton) {
        audioContainer.changeAudio(NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/a_new_beginning.mp3")!)
    }

    @IBAction func ButtonBPushed(sender: UIButton) {
        audioContainer.changeAudio(NSURL(string: "https://s3.amazonaws.com/cc0-tunes/nichecom/lets_dance.mp3")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

        audioContainer.reset()
    }
```

What you have to deal with is `StreamingAudioCacheContainer` only. `StreamingAudioCacheContainer` plays music when `changeAudio(url: NSURL)` is called. It downloads the tune from the Internet and plays streaming music. At the same time,  `StreamingAudioCacheContainer` stores the music data in the cache simultaneously.

When the URL appears again that is used previously in `changeAudio(url: NSURL)`, `StreamingAudioCacheContainer` does not download it from the Internet, but locally load from the cache and plays the tune immediately.

## Example project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Swift 2.0+

## Installation

Chorister is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Chorister"
```

## Author

Ryo Kato, http://katryo.com

## License

Chorister is available under the MIT license. See the LICENSE file for more info.

Chorister uses the modified version of great AwesomeCache ( https://github.com/aschuch/AwesomeCache ) created by Alexander Schuch ( http://schuch.me ), so you can find his name in the LICENSE file.

## Tunes

I used CC0 tunes from this site: http://www.nichecom.com/songs/
