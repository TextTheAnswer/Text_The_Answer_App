import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuizTimeUtility {
  // Daily quiz event times in UTC (9 AM, 3 PM, 9 PM)
  static const List<int> eventHoursUTC = [9, 15, 21];
  
  // Get the next event time in user's local timezone
  static DateTime getNextEventTime() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    
    // Find the next event today or tomorrow
    for (var hour in eventHoursUTC) {
      final eventTime = DateTime.utc(today.year, today.month, today.day, hour);
      
      if (eventTime.isAfter(now)) {
        // Convert to local time
        return eventTime.toLocal();
      }
    }
    
    // If all events today have passed, get the first event tomorrow
    final tomorrow = today.add(const Duration(days: 1));
    return DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day, eventHoursUTC[0]).toLocal();
  }
  
  // Get all today's events in local time
  static List<DateTime> getTodayEvents() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    
    return eventHoursUTC.map((hour) {
      return DateTime.utc(today.year, today.month, today.day, hour).toLocal();
    }).toList();
  }
  
  // Format event time for display
  static String formatEventTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // Check if an event is happening now (within a 15-minute window)
  static bool isEventHappeningNow() {
    final now = DateTime.now();
    final eventTimes = getTodayEvents();
    
    for (var eventTime in eventTimes) {
      // Event is considered "happening now" from exactly the start time to 15 minutes after
      if (now.isAfter(eventTime) && 
          now.isBefore(eventTime.add(const Duration(minutes: 15)))) {
        return true;
      }
    }
    
    return false;
  }
  
  // Check if we're in the waiting room period (5 minutes before an event)
  static bool isWaitingRoomTime() {
    final now = DateTime.now();
    final eventTimes = getTodayEvents();
    
    for (var eventTime in eventTimes) {
      // Waiting room is 5 minutes before the event
      if (now.isAfter(eventTime.subtract(const Duration(minutes: 5))) && 
          now.isBefore(eventTime)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Get the current or upcoming event time
  static DateTime getCurrentOrNextEventTime() {
    if (isEventHappeningNow()) {
      // Find which event is happening now
      final now = DateTime.now();
      final eventTimes = getTodayEvents();
      
      for (var eventTime in eventTimes) {
        if (now.isAfter(eventTime) && 
            now.isBefore(eventTime.add(const Duration(minutes: 15)))) {
          return eventTime;
        }
      }
    }
    
    if (isWaitingRoomTime()) {
      // Find which event is about to happen
      final now = DateTime.now();
      final eventTimes = getTodayEvents();
      
      for (var eventTime in eventTimes) {
        if (now.isAfter(eventTime.subtract(const Duration(minutes: 5))) && 
            now.isBefore(eventTime)) {
          return eventTime;
        }
      }
    }
    
    // If no event is happening now or about to happen, return the next event
    return getNextEventTime();
  }
  
  // Get time remaining until next event in minutes and seconds
  static Map<String, int> getTimeRemainingToNextEvent() {
    final now = DateTime.now();
    final nextEvent = getNextEventTime();
    final difference = nextEvent.difference(now);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;
    
    return {
      'hours': hours,
      'minutes': minutes,
      'seconds': seconds,
    };
  }
} 