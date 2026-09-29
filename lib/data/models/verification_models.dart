/// Domain models for the Aqarati verification / service-mode / key-custody
/// rework. Enums only — screens are wired in later phases.
library;

enum ServiceMode { broker, selfManaged }

extension ServiceModeLabel on ServiceMode {
  String get label {
    switch (this) {
      case ServiceMode.broker:
        return 'Aqarati Broker';
      case ServiceMode.selfManaged:
        return 'Do It Yourself';
    }
  }
}

enum CitizenshipStatus { omaniCitizen, omanResident, nonResident }

extension CitizenshipStatusLabel on CitizenshipStatus {
  String get label {
    switch (this) {
      case CitizenshipStatus.omaniCitizen:
        return 'Omani citizen';
      case CitizenshipStatus.omanResident:
        return 'Resident of Oman';
      case CitizenshipStatus.nonResident:
        return 'Not currently a resident of Oman';
    }
  }
}

enum PassportVerificationState {
  notStarted,
  uploading,
  submitted,
  pending,
  verified,
  failed,
  resubmissionRequired,
}

enum KeyCustodyState {
  notRequested,
  requested,
  awaitingHandover,
  inCustody,
  reserved,
  accessed,
  returnRequested,
  returned,
  completed,
}

extension KeyCustodyStateLabel on KeyCustodyState {
  String get label {
    switch (this) {
      case KeyCustodyState.notRequested:
        return 'Not requested';
      case KeyCustodyState.requested:
        return 'Requested';
      case KeyCustodyState.awaitingHandover:
        return 'Awaiting handover';
      case KeyCustodyState.inCustody:
        return 'In Aqarati custody';
      case KeyCustodyState.reserved:
        return 'Reserved for viewing';
      case KeyCustodyState.accessed:
        return 'Accessed';
      case KeyCustodyState.returnRequested:
        return 'Return requested';
      case KeyCustodyState.returned:
        return 'Returned';
      case KeyCustodyState.completed:
        return 'Completed';
    }
  }
}

/// Configurable Aqarati service/convenience fee rate — never hard-code 2%
/// inline; read this so a future admin/backend can supply the real rate.
const double kAqaratiServiceFeeRate = 0.02;

String formatServiceFeeRate() => '${(kAqaratiServiceFeeRate * 100).toStringAsFixed(0)}%';
