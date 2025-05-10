import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuizTimeUtility {
  // Daily quiz event time in UTC (9 AM only)
  static const int eventHourUTC = 9;
  
  // Get the next event time in user's local timezone
  static DateTime getNextEventTime() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    
    // Check if today's event has passed
    final todayEventTime = DateTime.utc(today.year, today.month, today.day, eventHourUTC);
    
    if (todayEventTime.isAfter(now)) {
      // Today's event is still upcoming
      return todayEventTime.toLocal();
    } else {
      // Today's event has passed, get tomorrow's event
      final tomorrow = today.add(const Duration(days: 1));
      return DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day, eventHourUTC).toLocal();
    }
  }
  
  // Get today's event in local time
  static DateTime getTodayEvent() {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    
    return DateTime.utc(today.year, today.month, today.day, eventHourUTC).toLocal();
  }
  
  // Get all upcoming events (for backward compatibility)
  static List<DateTime> getTodayEvents() {
    return [getTodayEvent()];
  }
  
  // Format event time for display
  static String formatEventTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // Check if an event is happening now (within a 10-minute window)
  static bool isEventHappeningNow() {
    final now = DateTime.now();
    final eventTime = getTodayEvent();
    
    // Event is considered "happening now" from exactly the start time to 10 minutes after
    return now.isAfter(eventTime) && 
           now.isBefore(eventTime.add(getTotalQuizDuration()));
  }
  
  // Check if we're in the waiting room period (5 minutes before an event)
  static bool isWaitingRoomTime() {
    final now = DateTime.now();
    final eventTime = getTodayEvent();
    
    // Waiting room is 5 minutes before the event
    return now.isAfter(eventTime.subtract(const Duration(minutes: 5))) && 
           now.isBefore(eventTime);
  }
  
  // Get the current or upcoming event time
  static DateTime getCurrentOrNextEventTime() {
    if (isEventHappeningNow()) {
      return getTodayEvent();
    }
    
    if (isWaitingRoomTime()) {
      return getTodayEvent();
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
  
  // Get total quiz duration (10 minutes)
  static Duration getTotalQuizDuration() {
    return const Duration(minutes: 10);
  }
  
  // Format duration to minutes and seconds string (MM:SS)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
} 