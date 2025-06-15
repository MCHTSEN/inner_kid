


extension GenericExtension<T> on T? {
  //Check Null
  bool get isNull => this == null;

  bool get isNotNull => this != null;
}