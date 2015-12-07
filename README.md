# About Me

Software developer from Moscow specializing in mobile apps for iOS. I have an experience of working for both small startups and huge internet companies. Of particular interest to me is Swift, which I started to experiment with from the day it was introduced. I've committed to the Open Source development and I've personally authored [multiple frameworks](https://github.com/kean).

# Contents

1. [Projects](#h_projects)
2. [Open Source](#h_open_source)
3. [Experience](#h_experience)
4. [Skills](#h_skils)
5. [Other Interests](#h_other_interests)
6. [Contacts](#h_contacts)

# <a name="h_projects"></a>Projects

### Fitness App by CleverBits (Objective-C)<a name="fitmeup"></a>

Workout tracker and personal assistant. Under development.

### [My World](https://itunes.apple.com/ru/app/moj-mir/id598556821?mt=8) by Mail.Ru (Objective-C)<a name="my_world"></a>

Our team was responsible for developing from the ground up a full featured (150k+ SLOC) iOS client for a social network. In this time period, we shipped a number of major releases. Some of my more notable contributions include:

- *Photosafe* (cloud photo storage), which I drove end-to-end as lead of iOS developer group. I've designed an app architecture and made major contributions to web API and UX. This project required a lot of complex decisions. Photosafe had to work offline and we needed fast and reliable sync with the server. I've suggested an API based on delta updates, similar to the one used by [Dropbox](https://www.dropbox.com/developers-v1/core/docs#delta). We went with this approach and had a single endpoint to construct an initial snapshot and keep it up to date. We've faced a lot of other challenges including: setting up concurrent Core Data and optimizing it to handle 50k+ entries, clustering photos to display them on a map, indexing and autouploading user assets and more.
- Instant Messenger on top of [Comet](https://en.wikipedia.org/wiki/Comet_(programming)) with text, custom emojis, images. We shipped this feature in just one month. The most challenging part was optimizing it to work smoothly on iPhone 4 (most common device at the time). I've optimized NIAttributedLabel to render multiple image attachments - we had to render custom emojis, added some memoization, moved layout calculations to the background.
- I personally drove multiple media features. The most prominent one was Photo Albums, which had a complex and rich UX. Another major and technically advanced feature was Image Editor. I implemented it from the ground up. All edits were non-destructive, it was very performant due to caching of intermediate results. It featured multiple image adjustments including Core Image filters, text on top of images, etc. Some of my other notable media features included multi-format Publisher, Photo Gallery with custom presentations, Image Picker based on Photos Kit.
- I authored multiple internal modules used throughout the project including ImageManager that was later [open sourced](#df_image_manager), UploadKit, MediaKit, CollectionViewKit, verification module etc.

Video and couple of screenshots of the features that I was involved with:

<img src="https://cloud.githubusercontent.com/assets/1567433/11615532/6e80e376-9c74-11e5-8ed6-5243292a349b.png" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615534/adfdaa66-9c74-11e5-840f-165d3ea7301b.png" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615535/b1c3ecdc-9c74-11e5-968b-6289e1a5e066.png" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615537/bacedf94-9c74-11e5-97f9-dd3e63a4df5e.png" width="20%"/>
<a href="https://youtu.be/efUWPsO4WUg"><img src="https://cloud.githubusercontent.com/assets/1567433/11615511/c6c27b18-9c73-11e5-9d98-1492a27d3b50.png" width="61%"/></a>

### Storymaker by Mail.Ru (Objective-C)<a name="storymaker"></a>

Over the last 4 months at Mail.Ru I was involved in prototyping an experimental blogging app for iOS. We've completed most of the core functionality for the project, but it was never released.

<img src="https://cloud.githubusercontent.com/assets/1567433/11615662/f4bb9d5c-9c77-11e5-8d7a-aedbc8fa223d.jpg" width="61%"/>

### [Vincent Decor](https://itunes.apple.com/ru/app/vincent-decor/id480639136?mt=8) by Aplica (Objective-C, C#)<a name="vincent_decor"></a>

One of the most intriguing features of this app is *Decorator*. It allows users to take a picture of their room and "magically" add decorative effects on the walls. This feature was built using OpenGL ES 2.0. This was my first experience with OpenGL. I've quickly got familiar with the basics, and I've also incorporated some performance best practices including VAO, VBO, mipmapping. I was also responsible for some of the back-end development on C#.

<img src="https://cloud.githubusercontent.com/assets/1567433/11615744/41d426de-9c7a-11e5-928a-664335ce9119.PNG" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615746/42155a3c-9c7a-11e5-8582-c74de2b98b2a.PNG" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615748/421a9be6-9c7a-11e5-85d3-5af315182079.PNG" width="20%"/>
<img src="https://cloud.githubusercontent.com/assets/1567433/11615745/42152832-9c7a-11e5-9042-c1e8c6507021.PNG" width="20%"/>

<img src="https://cloud.githubusercontent.com/assets/1567433/11615747/42179ed2-9c7a-11e5-8e2d-386eae2d875d.PNG" width="40.5%"/>

# <a name="h_open_source"></a>Open Source

### [Nuke](https://github.com/kean/Nuke) (Swift)<a name="nuke"></a>

Advanced Swift framework for loading, processing, caching, displaying and preheating images. This framework takes full advantage of Swift features, including generics, protocols, protocol extensions, enums with associated values etc. I've authored several [development guides](https://github.com/kean/Nuke/wiki) for this project, as well as a rich playground.

### [DFImageManager](https://github.com/kean/DFImageManager) (Objective-C)<a name="df_image_manager"></a>

Framework for image loading, processing, caching and preheating. I've started working on this project to improve image loading capabilities in [My World](#my_world) app. It had some major advantages over existing frameworks like [SDWebImage](https://github.com/rs/SDWebImage): uses `NSURLSession`, has optional [FLAnimatedImage](https://github.com/Flipboard/FLAnimatedImage) and [AFNetworking](https://github.com/AFNetworking/AFNetworking) integrations, automates [image preheating](https://github.com/kean/Nuke/wiki/Image-Preheating-Guide).

### [DFJPEGTurbo](https://github.com/kean/DFJPEGTurbo) (Objective-C)

Objective-C [libjpeg-turbo](http://www.libjpeg-turbo.org) wrapper (JPEG codec that uses SIMD instructions to accelerate baseline JPEG compression and decompression). This project allowed [My World](#my_world) app to enjoy about ~50% improvements in JPEG decompression speed. It has later become obsolete due to iOS improvements.

### [DFCache](https://github.com/kean/DFCache) (Objective-C)

Composite LRU cache with fast metadata built on top of UNIX extended file attributes


# <a name="h_experience"></a>Experience

- iOS Developer at CleverBits, June 2015 - Present
- iOS Developer at Mail.Ru, February 2013 - May 2015 (2 years 4 months)
- iOS Developer at Aplica, July 2012 - February 2013 (8 months)
- Senior Quality Engineer at Performance Lab, March 2011 - May 2012 (1 year 3 months)


# <a name="h_skils"></a>Skils

**Languages**
- Swift
- Objective-C
- C
- C#

**Technologies**
- Xcode
- Git, SVN (Cornerstone)
- CocoaPods, Carthage
- Can use Shell and write some basic scripts
- Auto Layout (VFL, [PureLayout](https://github.com/PureLayout/PureLayout))
- ARC/MRC, GCD, Core Data, Core Animation, Core Image, Photos Kit, Core Text, Keychain Services, XCTest, Core Motion, AVFoundation, etc
- Aware of RxSwift and ReactiveCocoa
- OpenGL ES 2.0
- Wireshark

**Interests**
- Functional programming
- Scheme
- Haskell

# <a name="h_education"></a>Education

- RSUH, Moscow - Specialist in Information Security, 2007 - 2012.

Courses:
- Bauman MSTU, Moscow - "Programming and Databases", 2010
- Bauman MSTU, Moscow - "The C Programming Language", 2010


# <a name="h_other_interests"></a>Other Interests

In additional to technical activities I enjoy traveling, and photography - you can find some of my photos at [flickr](https://www.flickr.com/photos/agrebenyuk/).


# <a name="h_contacts"></a>Contacts

- grebenyuk.alexander@gmail.com
- [linkedin](https://ru.linkedin.com/in/alexander-grebenyuk-3a0b4383)
- [github](https://github.com/kean)
- [twitter](https://twitter.com/a_grebenyuk)
- [facebook](https://www.facebook.com/agrebenyuk)
