import '../../../auth/domain/entities/user_status.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friendship_request.dart';

class FriendshipsState {
  const FriendshipsState({
    this.isFriendsLoading = false,
    this.isOnlineSectionsLoading = false,
    this.friends = const [],
    this.incomingRequests = const [],
    this.outgoingRequests = const [],
    this.suggestions = const [],
    this.myStatus = UserStatus.incognito,
    this.pendingFriendUsernames = const {},
    this.addFriendInput = '',
    this.errorMessage,
    this.onlineSectionsOffline = false,
    this.requestsErrorMessage,
    this.suggestionsErrorMessage,
    this.hasLoadedOnlineSections = false,
  });

  final bool isFriendsLoading;
  final bool isOnlineSectionsLoading;
  final List<Friend> friends;
  final List<FriendshipRequest> incomingRequests;
  final List<FriendshipRequest> outgoingRequests;
  final List<String> suggestions;
  final UserStatus myStatus;
  final Set<String> pendingFriendUsernames;
  final String addFriendInput;
  final String? errorMessage;
  final bool onlineSectionsOffline;
  final String? requestsErrorMessage;
  final String? suggestionsErrorMessage;
  final bool hasLoadedOnlineSections;

  List<FriendshipRequest> get pendingRequests => [
        ...incomingRequests,
        ...outgoingRequests,
      ];

  FriendshipsState copyWith({
    bool? isFriendsLoading,
    bool? isOnlineSectionsLoading,
    List<Friend>? friends,
    List<FriendshipRequest>? incomingRequests,
    List<FriendshipRequest>? outgoingRequests,
    List<String>? suggestions,
    UserStatus? myStatus,
    Set<String>? pendingFriendUsernames,
    String? addFriendInput,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? onlineSectionsOffline,
    String? requestsErrorMessage,
    bool clearRequestsErrorMessage = false,
    String? suggestionsErrorMessage,
    bool clearSuggestionsErrorMessage = false,
    bool? hasLoadedOnlineSections,
  }) {
    return FriendshipsState(
      isFriendsLoading: isFriendsLoading ?? this.isFriendsLoading,
      isOnlineSectionsLoading:
          isOnlineSectionsLoading ?? this.isOnlineSectionsLoading,
      friends: friends ?? this.friends,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      outgoingRequests: outgoingRequests ?? this.outgoingRequests,
      suggestions: suggestions ?? this.suggestions,
      myStatus: myStatus ?? this.myStatus,
      pendingFriendUsernames:
          pendingFriendUsernames ?? this.pendingFriendUsernames,
      addFriendInput: addFriendInput ?? this.addFriendInput,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      onlineSectionsOffline:
          onlineSectionsOffline ?? this.onlineSectionsOffline,
      requestsErrorMessage: clearRequestsErrorMessage
          ? null
          : (requestsErrorMessage ?? this.requestsErrorMessage),
      suggestionsErrorMessage: clearSuggestionsErrorMessage
          ? null
          : (suggestionsErrorMessage ?? this.suggestionsErrorMessage),
      hasLoadedOnlineSections:
          hasLoadedOnlineSections ?? this.hasLoadedOnlineSections,
    );
  }
}