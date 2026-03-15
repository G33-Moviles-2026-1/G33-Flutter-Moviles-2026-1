enum BookingPurpose {
  studyAlone,
  chillAlone,
  studySmallGroup,
  hangOutWithFriends,
  tutoringBigGroup,
}

extension BookingPurposeX on BookingPurpose {
  String get label {
    switch (this) {
      case BookingPurpose.studyAlone:
        return 'Study alone';
      case BookingPurpose.chillAlone:
        return 'Chill alone';
      case BookingPurpose.studySmallGroup:
        return 'Study in small group';
      case BookingPurpose.hangOutWithFriends:
        return 'Hang out with friends';
      case BookingPurpose.tutoringBigGroup:
        return 'Tutoring for big groups';
    }
  }

  String get backendKey {
    switch (this) {
      case BookingPurpose.studyAlone:
        return 'study_alone';
      case BookingPurpose.chillAlone:
        return 'chill_alone';
      case BookingPurpose.studySmallGroup:
        return 'study_small_group';
      case BookingPurpose.hangOutWithFriends:
        return 'hangout_friends';
      case BookingPurpose.tutoringBigGroup:
        return 'tutoring_big_group';
    }
  }

  static BookingPurpose fromBackendKey(String value) {
    switch (value) {
      case 'study_alone':
        return BookingPurpose.studyAlone;
      case 'chill_alone':
        return BookingPurpose.chillAlone;
      case 'study_small_group':
        return BookingPurpose.studySmallGroup;
      case 'hangout_friends':
        return BookingPurpose.hangOutWithFriends;
      case 'tutoring_big_group':
        return BookingPurpose.tutoringBigGroup;
      default:
        throw ArgumentError('Unknown booking purpose: $value');
    }
  }
}