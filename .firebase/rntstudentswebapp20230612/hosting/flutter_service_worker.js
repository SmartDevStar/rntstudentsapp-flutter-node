'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.json": "4f8bade2a948ef8136b591aab763b552",
"assets/AssetManifest.smcbin": "a3e5765f08351c96a9c99193f3efdfdc",
"assets/assets/fonts/0_Yekan.ttf": "12e5a8dd5bb2e75c1f00b8a3cfc237a2",
"assets/assets/fonts/B_Yekan.ttf": "52ce4de2efeeb8b18dcbd379711224f3",
"assets/assets/images/avatar.png": "f77a7cad349bf8dd0837045decf328b4",
"assets/assets/images/bell.svg": "efbb8d29ec2e1392ee604d2cce283747",
"assets/assets/images/chat.svg": "4905f3aa4ed2a5dc735ff94636849483",
"assets/assets/images/class.svg": "7bf9f03a5285f941238acf17151a2ad7",
"assets/assets/images/contactus.svg": "4b3e33c512bd63c184cde3dc2e38f803",
"assets/assets/images/contactus1.svg": "a68dba8278bb9a905c5f5a373c08475b",
"assets/assets/images/duration.svg": "36426fb8f85304ee7a1e15a6b6479c47",
"assets/assets/images/home.svg": "52c5d982e39aebdff170015e2898316e",
"assets/assets/images/invoice.svg": "d979c0d118eb91335a056a4fe1b9394d",
"assets/assets/images/logo.png": "1cef9708cdd332625708a1631adedbd2",
"assets/assets/images/logo1.png": "5c7a67a77802adddbefc4fa5017acffa",
"assets/assets/images/message.svg": "50aae1ae4553746ae9fc3bf9e2a45bc8",
"assets/assets/images/money.svg": "3b1785472905f514762d023179618cd2",
"assets/assets/images/password.svg": "712cbbd59076ab577a404d62eda04439",
"assets/assets/images/plus.svg": "2287a4b2646673c3cdfb4f874a0eab38",
"assets/assets/images/record.svg": "3d6c51e699b53c21b00ff8a4a3003cfd",
"assets/assets/images/record_class.png": "e0135ccb6f30dd5c3d9ffd21d42787cd",
"assets/assets/images/refresh.svg": "7a65fcaf6c82173e6cd5560c42b7b78b",
"assets/assets/images/register.svg": "7b59375d7918f6cc6a1084e00168a9ab",
"assets/assets/images/rescources.svg": "4b9205f82b26157694b1ceba01a52d55",
"assets/assets/images/schedule.svg": "60da2a3160ae1223c536f96e6cf51c31",
"assets/assets/images/time.svg": "6ca74ad7196a8510d89a73f3f6d920f3",
"assets/assets/images/user.svg": "7ee4a01b481b6058e8db8ecba1706c23",
"assets/FontManifest.json": "5219c7fc94dce86327d887893db473fb",
"assets/fonts/MaterialIcons-Regular.otf": "682c5f854f8f97ff2073a02c14bf8e94",
"assets/NOTICES": "6bbffed6e36e31a139a59237ca19ac1a",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"canvaskit/canvaskit.js": "76f7d822f42397160c5dfc69cbc9b2de",
"canvaskit/canvaskit.wasm": "f48eaf57cada79163ec6dec7929486ea",
"canvaskit/chromium/canvaskit.js": "8c8392ce4a4364cbb240aa09b5652e05",
"canvaskit/chromium/canvaskit.wasm": "fc18c3010856029414b70cae1afc5cd9",
"canvaskit/skwasm.js": "1df4d741f441fa1a4d10530ced463ef8",
"canvaskit/skwasm.wasm": "6711032e17bf49924b2b001cef0d3ea3",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"firebase-debug.log": "ae421441b1f5d32c2cdcdd39419d99dd",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "bd594f73013958f616d43a0c3083ebab",
"/": "bd594f73013958f616d43a0c3083ebab",
"main.dart.js": "6c4c1c82260a808584b1af31b9a08f23",
"manifest.json": "8159e256d62a19bc525b6f6048438909",
"version.json": "4dbab2d9f3824b1f677dd6f5f66623f5"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
