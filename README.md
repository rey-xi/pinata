# Pinata API Consumer


# Welcome to Pinata Docs

##### Perfect end point you need to use IPFS via Pinata Gateway

<hr/>

<img alt="Pinata" height="200" src="https://cdn.pixabay.com/photo/2013/07/12/14/08/drawing-pin-147814_960_720.png" width="200"/>

<hr/>

## What is Pinata?

Pinata is an NFT media management service that allows users to host, manage &
share files of any kind on the blockchain of their choice. As an IPFS pinning
service, we focus on giving both technical and non-technical creators a fast, 
easy, and reliable way to share content without limits.

<hr/>

## What does "pinning" mean?

When you “pin” data on an IPFS node, you are telling that node that the data
is important and it should be saved. A node is a program that connects you to
IPFS and stores files.

Pinning prevents important data from being deleted from your node. You and only
you can control and pin data on your node(s)—you can not force other nodes on 
the IPFS network to pin your content for you. So, to guarantee your content 
stays pinned, you have to run your own IPFS nodes.

Once your file is pinned to IPFS, you have full control to share, distribute, 
monetize and share your files however you’d like.

Further reading: [What is an IPFS Pinning Service](https://medium.com/pinata/what-is-an-ipfs-pinning-service-f6ed4cd7e475)

## Getting Started

`pubspec.yaml`

### Add super text to pubspec.yaml file

```yaml

...
environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  pinata:
    git: https://github.com/rey-xi/pinata.git 
...

```

### Or

```yaml

...
environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  pinata: ^0.0.1
...

```

## Usage

#### Pinata 

Pinata interface for interacting with Pinata gateway. Contains two constructors
[viaJWT] which takes a required [JWT]; and [viaParts] which takes required API
key and API Secret. Pinata houses all functions provided from Pinata API Gateway.

Pinata Constructors
- Pinata.viaJWT()
- Pinata.viaParts()

Pinata Interface

  - **log**
     This Getter that ensures 

  - pins
  - pinJobs
  - descendants
  - queryPins()
  - pinFile()
  - pinDirectory()
  - pinBytes()
  - pinJson()
  - pinByID()
  - createDescendant()
  - revokeDescendant()

More Detailed Documentation coming soon.

## Working Example:
```dart
void main() {
  //...
  var pinata = Pinata.viaPair(
    name: 'Rey Pinata',
    apiKey: 'API KEY',
    secret: 'API SECRET',
  );
  pinata = Pinata.viaJWT(
    name: 'Rey Pinata',
    jWT: 'JWT',
  );
  print(pinata.pinFile(File('FILE PATH')));
  print(pinata.pins);
}
```
### Thanks.