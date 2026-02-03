enum UserPlan {
  free,
  subscription;

  int get maxResumes {
    switch (this) {
      case UserPlan.free:
        return 1;
      case UserPlan.subscription:
        return 999999; // Effectively unlimited
    }
  }

  bool get canSyncToCloud {
    switch (this) {
      case UserPlan.free:
        return false;
      case UserPlan.subscription:
        return true;
    }
  }

  int get maxOnlineResumes {
    switch (this) {
      case UserPlan.free:
        return 0; // Cannot sync
      case UserPlan.subscription:
        return 999999; // Unlimited
    }
  }

  int get maxExports {
    switch (this) {
      case UserPlan.free:
        return 2;
      case UserPlan.subscription:
        return 999999; // Unlimited
    }
  }

  String get displayName {
    switch (this) {
      case UserPlan.free:
        return 'Free';
      case UserPlan.subscription:
        return 'Pro';
    }
  }
}
