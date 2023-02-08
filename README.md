# Pinata API Consumer


# Welcome to Flutter Pinata by Rey Docs

##### Perfect end point you need to use IPFS via Pinata Gateway

<hr/>

## What is Pinata?

Pinata is an NFT media management service that allows users to host, manage &
share files of any kind on the blockchain of their choice. As an IPFS pinning
service, we focus on giving both technical and non-technical creators a fast, 
easy, and reliable way to share content without limits.

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

<hr/>

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

Extends _PinataAPI to expose it's interface that can be used to communicate
with IPFS via Pinata online Gateway. IPFS means Interplanetary File System. 
It's a decentralised storage network for files.

There are 3 major constructors to access Pinata API Interface:
  - Pinata.login
  - Pinata.viaPair
  - Pinata.viaJWT

Pinata.test - Pinata test interface can be used to access Pinata test IPFS 
Network provided by Rey. Works with full fledged editor access confined to
Rey local space.


#### PinataAPI
The interface for communicating with Pinata IPFS Gateway API. Can be used to
pin and unpin files among many other Pinata data, pinning and admin services 
available on Pinata IPFS Gateway.

IPFS means Interplanetary File System. It's a decentralised storage network 
for files. Only Pinata keys with admin access can use Pinata admin features.

See [Pinata](#Pinata) for more Usage cases.

###### Example 
```dart
var pinata = Pinata.viaPair(
  name: 'Rey Pinata',
  apiKey: 'API KEY',
  secret: 'API SECRET',
);
```

#### Pinata Key

Pinata API Key complete details with both serial, userID and API key. This
class has cannot interact with Pinata cloud gateway. In order to access 
Pinata api key interface ie. _PinataAPI, use PinataKey.api.

###### Example
```dart
void main() async {
  final key = (await Pinata.test.keys).first;
}
```

#### Pin

Pin data. A struct containing a typical pin details. A pin has no constructor,
so it can't be created locally. Change pin meta details via update and delete 
via unpin. Pending Pin event data are described by this package as PinJobs.
PinJob applies only to pins created via _PinataAPI.pinFromAddress.

###### Example
```dart
void main() async {
  final pin = (await Pinata.test.pins).first;
}
```


#### Key Access

Enum based constructed class that serves as permission or access negotiation
to Pinata api keys. Key Access describes what Pinata cloud api features a 
pinata key has access to.

###### Example
```dart
final key = adminKey.createKey(
  name: 'My new key',
  access: [KeyAccess.admin],
);
```


## Working Example:
```dart
void main() async {
  //...
  // var pinata = Pinata.viaPair(
  //   name: 'Rey Pinata',
  //   apiKey: 'API KEY',
  //   secret: 'API SECRET',
  // );
  // pinata = Pinata.viaJWT(
  //   name: 'Rey Pinata',
  //   jWT: 'JWT',
  // );
  final pin;
  pinata = Pinata.test;
  print(await pinata.pinFile(File('FILE PATH')));
  print(pin = await pinata.pins);
  print(await pin.update(name: 'New Pin'));
}
```
##### This documentation and project is still under development. Yet fully active and safe to use
### Thanks.