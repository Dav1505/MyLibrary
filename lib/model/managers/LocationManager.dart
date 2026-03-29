import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../ui/behaviors/AppLocalizations.dart';

class LocationManager{
  Future<bool> handleLocationPermission(BuildContext context) async{
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate("location_disabled")
          )));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.translate("location_denied")
            )));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate("location_permanently_denied")
          )));
      return false;
    }
    return true;
  }

  Future<String?> getLocation(double latitude, double longitude) async{
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks[0];
      return "${place.locality ?? ''}, ${place.country}";
    }
    return null;
  }
}