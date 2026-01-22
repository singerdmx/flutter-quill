/// Controller for managing mention/tag suggestion list refresh
/// 
/// Use this to refresh the suggestion list when your data changes.
/// Create an instance and pass it to MentionTagWrapper, then call
/// [refresh] when you need to update the list.
class MentionTagController {
  MentionTagController();

  /// Callback to refresh the suggestion list
  /// This is set internally by MentionTagWrapper
  void Function()? _refreshCallback;

  /// Refresh the suggestion list
  /// Call this method when your data source has been updated
  void refresh() {
    _refreshCallback?.call();
  }

  /// Internal method to set the refresh callback
  /// This is called by MentionTagWrapper
  /// Making it public so MentionTagWrapper can access it
  void setRefreshCallback(void Function() callback) {
    _refreshCallback = callback;
  }
}
