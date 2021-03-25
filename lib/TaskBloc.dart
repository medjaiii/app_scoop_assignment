import 'dart:async';
import "package:flutter/material.dart";
import 'package:test_app_scoop/TaskModel.dart';
// import 'package:test_app_scoop/taskModel.dart';

class TaskBloc {
  final List<TaskModel> dataList = [];

  DataBloc() {
    _dataListStreamController.add(dataList);
  }

  onAddAction(TaskModel data) {
      dataList.add(data);
    _getDataListStreamSink.add(dataList);
    sortAccordingToDate();
  }

  onRemoveAction(TaskModel data) {
      dataList.remove(data);
    _getDataListStreamSink.add(dataList);
    sortAccordingToDate();
  }

  sortAccordingToDate(){
    dataList.sort((a,b) => a.date.compareTo(b.date));
  }


  final _dataListStreamController = StreamController<List<TaskModel>>();

  Stream<List<TaskModel>> get getDataListStream => _dataListStreamController.stream;

  StreamSink<List<TaskModel>> get _getDataListStreamSink =>
      _dataListStreamController.sink;

  void dispose() {
    _dataListStreamController.close();
  }
}
