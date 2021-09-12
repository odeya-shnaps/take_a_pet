//
// class ImageCache {
//   ImageCache._privateConstructor();
//
//   static final ImageCache _instance = ImageCache._privateConstructor();
//
//   static ImageCache get instance => _instance;
//
//   Map<String, String> _urlCache = Map();
//
//   Future<String> getUrl(String imageKey) async {
//     String url = _urlCache![imageKey];
//
//     if (url == null) {
//       try {
//         url = (await Amplify.Storage.getUrl(key: imageKey)).url;
//         _urlCache[imageKey] = url;
//       } catch (e) {
//         print(e);
//       }
//     }
//
//     return url;
//   }
// }