enum MessageType{
  text,
  image,
  unknown
}
extension MessageTypeExtension on MessageType {
  int get id {
    switch (this) {
      case MessageType.text:
        return 1;
      case MessageType.image:
        return 2;
      default:
        return 0;
    }
  }
}