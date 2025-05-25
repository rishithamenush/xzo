import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_layer.dart';


class NotificationService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final String _collectionName = "notifications";
  final UserProvider _userProvider = UserProvider();

  // notify user if a place is added near them by 10 Km.
  Future<void> notifyUsers(double placeLatitude, double placeLongitude,String placeName) async {
    UserList userList = await _userProvider.userList;
  }

  // get the user notifications from database
  Future<NotificationList> getUserNotifications() async {
    QuerySnapshot notificationsData = await _fireStore
        .collection(_collectionName)
        .where('userId', isEqualTo: sharedUser.id)
        .get()
        .whenComplete(() {
      log("Service get Notifications for user done");
    }).catchError((error) {
      log(error.toString());
    });

    Map<String, dynamic> data = {};
    NotificationModel tempModel;
    NotificationList notificationList = NotificationList(notifications: []);
    for (var item in notificationsData.docs) {
      data["id"] = item.get("id");
      data["userId"] = item.get("userId");
      data["text"] = item.get("text");
      data["date"] = item.get("date");
      data["isRead"] = item.get("isRead");


      tempModel = NotificationModel.fromJson(data);
      notificationList.notifications.add(tempModel);
    }
    return notificationList;
  }
  Future<void> updateUserNotifications() async {
    QuerySnapshot notificationsData = await _fireStore
        .collection(_collectionName)
        .where('userId', isEqualTo: sharedUser.id)
        .where('isRead', isEqualTo:false)
        .get();

    for(var item in notificationsData.docs){
      _fireStore
          .collection(_collectionName)
          .doc(item.id)
          .update({"isRead":true})
          .whenComplete(() {
        log("UPDATE notification done");
      }).catchError((error) {
        log(error.toString());
      });
    }
  }
  }
