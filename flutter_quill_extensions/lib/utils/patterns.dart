RegExp base64RegExp = RegExp(
  r'^(?:[A-Za-z0-9+\/][A-Za-z0-9+\/][A-Za-z0-9+\/][A-Za-z0-9+\/])*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$',
);

final imageRegExp = RegExp(
  r'https?://.*?\.(?:png|jpe?g|gif|bmp|webp|tiff?)',
  caseSensitive: false,
);

final videoRegExp = RegExp(
  r'\bhttps?://\S+\.(mp4|mov|avi|mkv|flv|wmv|webm)\b',
  caseSensitive: false,
);
final youtubeRegExp = RegExp(
  r'^((?:https?:)?\/\/)?((?:www|m)\.)?((?:youtube(-nocookie)?\.com|youtu.be))(\/(?:[\w\-]+\?v=|embed\/|live\/|v\/)?)([\w\-]+)(\S+)?$',
  caseSensitive: false,
);
