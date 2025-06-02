import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:l8fe/ble/bluetooth_ctg_service.dart';


class DeviceListScreen extends StatefulWidget {
  final PageController pageController;
  const DeviceListScreen({super.key, required this.pageController});

  @override
  State createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceListScreen> with AutomaticKeepAliveClientMixin {
  late List<BluetoothDevice> list;

  bool isFetching = false;


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    //_startScanning()
    list = FlutterBluePlus.connectedDevices;
    widget.pageController.position.addListener(() {
      if(widget.pageController.page!.round()==1){
        refresh();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  listen(){

  }


  void _startScanning() {
    if(!FlutterBluePlus.isScanningNow ){
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    //list = FlutterBluePlus.connectedDevices;//.where((element) => element.platformName.toString().contains("L8")).toList();
    debugPrint("${FlutterBluePlus.connectedDevices.toList()}");
    return Stack(
      children: [
        Container(
          color: Theme
              .of(context)
              .colorScheme
              .primaryContainer,
          padding: EdgeInsets.symmetric(horizontal:16.w,vertical: 24.h),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Fetosense Devices",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.sp,
                                color: Colors.white),
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*ElevatedButton(
                                child: const Text('Scan'),
                                onPressed: !widget.scannerState.scanIsInProgress
                                    ? _startScanning
                                    : null,
                              ),
                              ElevatedButton(
                                child: const Text('Stop'),
                                onPressed: widget.scannerState.scanIsInProgress
                                    ? widget.stopScan
                                    : null,
                              ),*/
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 0.3.sh,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          if(list.where((element) => element.platformName.toString().contains("L8")).toList().isNotEmpty)
                          ...list.where((element) => element.platformName.toString().contains("L8")).toList().map(
                              (device) =>
                              BluetoothCard(
                                type: "Fetosense Plus",
                                  data: {
                                "name": (device.platformName.isNotEmpty
                                    ? device.platformName
                                    : "Unnamed"),
                                "macId": device.remoteId.str,
                                "RSSI": "${device.mtuNow}"
                              })).toList(),
                          if(list.isEmpty)
                            Text(
                              "No Fetosense device found.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: Colors.white54),
                              textAlign: TextAlign.center,
                            ),


                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              SizedBox(
                width: 0.3.sw,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          /*ElevatedButton(
                            onPressed: (){
                              const methodChannel = MethodChannel('com.carenx.app/callback');
                              methodChannel.invokeMethod("startBpBleTransfer");
                            },
                            child:  Text('transfer',style: Theme.of(context).textTheme.titleMedium,),
                          ),*/
                          Text(
                            "SpO2 Device",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.sp,
                                color: Colors.white),
                          ),
                          /*ElevatedButton(
                            onPressed: (){
                              const methodChannel = MethodChannel('com.carenx.app/callback');
                              methodChannel.invokeMethod("startBpBleScan");
                            },
                            child:  Text('Scan',style: Theme.of(context).textTheme.titleMedium,),
                          ),*/
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 0.3.sh,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          if(list.where((element) => element.platformName.toString().toLowerCase().contains("sp001")).toList().isNotEmpty)
                            ...list.where((element) => element.platformName.toString().toLowerCase().contains("sp001")).toList().map(
                                    (device) =>
                                    BluetoothCard(
                                        type: "SpO2",
                                        data: {
                                      "name": (device.platformName.isNotEmpty
                                          ? device.platformName
                                          : "Unnamed"),
                                      "macId": device.remoteId.str,
                                      "RSSI": "${device.mtuNow}"
                                    })).toList(),
                          if(list.isEmpty)
                            Text(
                              "No SpO2 device found.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: Colors.white54),
                              textAlign: TextAlign.center,
                            ),


                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              SizedBox(
                width: 0.3.sw,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /*ElevatedButton(
                            onPressed: (){
                              const methodChannel = MethodChannel('com.carenx.app/callback');
                              methodChannel.invokeMethod("startBpBleTransfer");
                            },
                            child:  Text('transfer',style: Theme.of(context).textTheme.titleMedium,),
                          ),*/
                          SizedBox(width: 10.w,),
                          Text(
                            "BP Device",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.sp,
                                color: Colors.white),
                          ),
                          ElevatedButton(
                            onPressed: (){
                              const methodChannel = MethodChannel('com.carenx.app/callback');
                              methodChannel.invokeMethod("startBpBleScan");
                            },
                            child:  Text('Pair',style: Theme.of(context).textTheme.titleSmall,),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 0.3.sh,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children: [
                          if(list.where((element) => element.platformName.toString().contains("BLESmart")).toList().isNotEmpty)
                            ...list.where((element) => element.platformName.toString().contains("BLESmart")).toList().map(
                                    (device) =>
                                    BluetoothCard(
                                        type: "Bp Monitor",
                                        data: {
                                      "name": (device.platformName.isNotEmpty
                                          ? device.platformName
                                          : "Unnamed"),
                                      "macId": device.remoteId.str,
                                      "RSSI": "${device.mtuNow}"
                                    })).toList(),
                          if(list.isEmpty)
                            Text(
                              "No BP device found.",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: Colors.white54),
                              textAlign: TextAlign.center,
                            ),


                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

            ],
          ),
        ),
        Positioned(
          left : 16.w,
          top: 8.h,
          child: IconButton(
            iconSize: 32.w,
            icon: isFetching?const CircularProgressIndicator(color: Colors.white,)
                : const Icon(Icons.refresh, size: 32, color: Colors.white),
            onPressed: (){
              isFetching = true;
              setState(() {});
              Future.delayed(
                  const Duration(seconds: 2),()=>setState(() {
                isFetching = false;
              }));
              refresh();
            },
          ),
        ),

      ],
    );

  }

  void refresh() {
    list = FlutterBluePlus.connectedDevices;
    BluetoothCTGService.instance.listenToNativeEvents();
    setState(() {});
  }
}


class BluetoothCard extends StatelessWidget {
  final Color? color;
  final String? type;
  final Map<String,dynamic> data;

  const BluetoothCard({
    Key? key,
    this.color,
    required this.data, required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.25.sw,
      height: 0.2.sh,
      margin: EdgeInsets.all(16.w),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color:  const Color.fromRGBO(68, 69, 84, 1.0) ,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        children: [
           Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  type??"Fetosense",
                ),
                const Icon(Icons.bluetooth,
                  size: 36,
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Text(
                  data["name"],
                  style: const TextStyle(
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
          ),
          /*Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data["macId"],
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Text('RSSI: '),
                const SizedBox(width: 4),
                Text(
                  data["RSSI"],
                ),
              ],
            ),
          ),*/
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data["macId"],
                  style: const TextStyle(
                    fontSize: 12.0,
                  ),
                ),
                Row(
                  children: [
                    const Text('RSSI: '),
                    const SizedBox(width: 4),
                    Text(
                      data["RSSI"],
                    ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
