enum BookingPurpose {
  studyAlone,
  studySmallGroup,
  chillAlone,
  hangOutWithFriends,
  tutoringBigGroup,
}

extension BookingPurposeX on BookingPurpose {
  String get label {
    switch (this) {
      case BookingPurpose.studyAlone:
        return 'Study alone';
      case BookingPurpose.studySmallGroup:
        return 'Study in small group';
      case BookingPurpose.chillAlone:
        return 'Chill alone';
      case BookingPurpose.hangOutWithFriends:
        return 'Hang out with friends';
      case BookingPurpose.tutoringBigGroup:
        return 'Tutoring for big groups';
    }
  }

  String get backendKey {
    // Useful later when backend expects a string value.
    switch (this) {
      case BookingPurpose.studyAlone:
        return 'study_alone';
      case BookingPurpose.studySmallGroup:
        return 'study_small_group';
      case BookingPurpose.chillAlone:
        return 'chill_alone';
      case BookingPurpose.hangOutWithFriends:
        return 'hang_out_friends';
      case BookingPurpose.tutoringBigGroup:
        return 'tutoring_big_group';
    }
  }
}