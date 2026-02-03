import 'package:equatable/equatable.dart';

/// Contact information section of the resume
class Contact extends Equatable {
  final String id;
  final String email;
  final String phone;
  final String? website;
  final String? linkedIn;
  final String? github;
  final String? twitter;
  final String? address;
  final String? city;
  final String? country;

  const Contact({
    required this.id,
    required this.email,
    required this.phone,
    this.website,
    this.linkedIn,
    this.github,
    this.twitter,
    this.address,
    this.city,
    this.country,
  });

  Contact copyWith({
    String? id,
    String? email,
    String? phone,
    String? website,
    String? linkedIn,
    String? github,
    String? twitter,
    String? address,
    String? city,
    String? country,
  }) {
    return Contact(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      linkedIn: linkedIn ?? this.linkedIn,
      github: github ?? this.github,
      twitter: twitter ?? this.twitter,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  factory Contact.empty(String id) => Contact(
    id: id,
    email: '',
    phone: '',
  );

  bool get isEmpty => email.isEmpty && phone.isEmpty;
  bool get isNotEmpty => !isEmpty;

  String get location {
    final parts = <String>[];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    website,
    linkedIn,
    github,
    twitter,
    address,
    city,
    country,
  ];
}

