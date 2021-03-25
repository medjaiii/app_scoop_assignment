import 'dart:convert';

TaskModel taskModelFromJson(String str) => TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
    TaskModel({
        this.task,
        this.date,
        this.desc,
    });

    String task;
    String date;
    String desc;

    //created this class only for api calling that's all
    
    factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        task: json["Task"],
        date: json["date"],
        desc: json["Desc"],
    );

    Map<String, dynamic> toJson() => {
        "Task": task,
        "date": date,
        "Desc": desc,
    };
}
