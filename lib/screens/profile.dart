import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/imageController.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _homepageState();
}

class _homepageState extends State<Profile> {
  final ImageController imageController = Get.put(ImageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text('Profile'),
          centerTitle: true,
        ),
        body: Obx(
           () {
            return Column(
              children: [
                kIsWeb
                    ? Image.memory(imageController.memoryImage.value,height: 50,width:50)
                    : Image.file(imageController.image.value),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[ ElevatedButton(
                      child: Text('pick image'),
                      onPressed: () => imageController.pickImage(
                          isFromGallary: true, context: context)),

                          SizedBox(width: 20,),

                          ElevatedButton( child: Text('update image'),onPressed:()=>{  },)

                  ]
                        
                ),
                
              ],
            );
          }
        ));
  }
}
