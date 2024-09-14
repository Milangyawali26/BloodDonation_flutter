
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageController extends GetxController{
  var image =File("").obs;
  var memoryImage=Uint8List.fromList([]).obs;
  final _picker=ImagePicker();



// 
// void updateImage();
// this function is to piick image form gallary

void pickImage({required bool isFromGallary, required BuildContext context}) async {
  if(kIsWeb){
    var localImage =await _picker.pickImage(
      source: isFromGallary? ImageSource.gallery : ImageSource.camera,
      imageQuality:50
    );
    if(localImage!=null)
    {
      memoryImage.value=await localImage.readAsBytes();
      memoryImage.refresh();
      update();
    }
  }else{
    final permResult = await Permission.storage.request();
    if(permResult.isGranted){
      var localImage=await _picker.pickImage(source: ImageSource.gallery,imageQuality: 50);

      if (localImage !=null){
        image.value =File(localImage.path);
        image.refresh();
        update();
      }
      else{
      if(context.mounted){
        showDialog(
    context: context,
    builder: (dialogContext)=> AlertDialog(
      backgroundColor: Colors.transparent,
      
        icon:(Icon(Icons.warning)),
        
       title: Text("storage Permission"),
       actions:[
        TextButton(
          onPressed:()=>Navigator.of(dialogContext).pop(),
          child:Text("ok")
        )
       ]

      )
    
        );
      }
      }
    }
  }
}
}