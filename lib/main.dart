import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:test_app_scoop/TaskBloc.dart';

import 'TaskModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//gloabal params
String date=DateTime.now().year.toString()+"-"+DateTime.now().month.toString()+"-"+DateTime.now().day.toString();
String dateToday=DateTime.now().year.toString()+"-"+DateTime.now().month.toString()+"-"+DateTime.now().day.toString();
  TextEditingController taskController=TextEditingController();
  TextEditingController descController=TextEditingController();
  TextEditingController editTaskCon=TextEditingController();
  TextEditingController editDescCon=TextEditingController();

void showSnack(context,msg){
  final snackBar = SnackBar(content: Text(msg));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TaskBloc _taskBloc=TaskBloc();


  @override
  void initState() {
    // _taskBloc.onAddAction(TaskModel(task: '',desc: '',date: ''));
    super.initState();
  }
  @override
  void dipose(){
    _taskBloc.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                   //date text field
                   SizedBox(height:MediaQuery.of(context).size.height*0.02),
                   DeadlineArea(),
                   TaskTextArea(),
                   DescriptionArea(),
                   SizedBox(height:MediaQuery.of(context).size.height*0.02),
                   Submit(bloc:_taskBloc),
                   SizedBox(height:MediaQuery.of(context).size.height*0.02),
                   Container(
                     width: MediaQuery.of(context).size.width,
                     padding: EdgeInsets.symmetric(vertical:5),
                     decoration: BoxDecoration(
                       border: Border(
                         bottom: BorderSide(color: Colors.black,width: 2),
                         top: BorderSide(color: Colors.black,width: 1),
                       )
                     ),
                     child: Text('TODO',textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20),),
                   ),
                  //  TabHeading(),
                   TaskListView(bloc:_taskBloc),                 
              ],
            ),
          ),
        ),      
      ),
    );
  }
}

class Submit extends StatefulWidget{
  TaskBloc bloc;
  Submit({@required this.bloc});
  @override
  _SubmitState createState() => _SubmitState();
}

class _SubmitState extends State<Submit> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      width: MediaQuery.of(context).size.width *0.8,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
        elevation: 10,color: Colors.blue,
        onPressed: (){
          if(taskController.text!='' && descController.text!='' && date!='')
          {widget.bloc.onAddAction(
            // TaskModel(task:'task',date: "032-21-2",desc: "hello")
            TaskModel(task:taskController.text,date: date,desc: descController.text)
            );
          taskController.text='';
          descController.text='';
          showSnack(context, 'Added Task');
          }else showSnack(context, 'Data Incomplete');
        },
        child: Text('Save',style: TextStyle(color: Colors.white,fontSize: 18),),)); 
  }
}

class TaskListView extends StatefulWidget{
  TaskBloc bloc;

  TaskListView({@required this.bloc});

  @override
  _TaskListViewState createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:StreamBuilder<List<TaskModel>>(
        stream: widget.bloc.getDataListStream,
        builder: (context,snapshot){
          return 
          (snapshot.data==null || snapshot.data.isEmpty)?Container(
        height: MediaQuery.of(context).size.height*0.4,
        child: Center(child: Text('No tasks now ..',style: TextStyle(fontSize: 18,color:Colors.black),),),):
          ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.data.length,
        itemBuilder: (context,index){
          return Dismissible(
            key: Key(snapshot.data[index].task),
            background: Container(
                padding:EdgeInsets.symmetric(horizontal:20),color:Colors.red,child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.delete,color: Colors.white,),
                  Icon(Icons.delete,color: Colors.white,),
                ],
              ),
            ),
          onDismissed: (direction) {
            setState(() {
              showSnack(context, 'Task Completed !!');
              widget.bloc.onRemoveAction(snapshot.data[index]);
            });
          },
            child: GestureDetector(
              onTap: ()async{
                editDescCon.text=snapshot.data[index].desc;
                editTaskCon.text=snapshot.data[index].task;
                await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20),
                    titlePadding: EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    title: Row(
                      children: <Widget>[
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1,
                        )
                      ],
                    ),
                    children: <Widget>[
                      Form(
                        // key: dialogFormKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller:
                                  editTaskCon,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .hintColor),
                              // keyboardType: TextInputType.n,
                              decoration:
                                  InputDecoration(
                                    hintText: 'task',
                                    labelText: 'Task',
                                    hintStyle: Theme.of(context).textTheme.bodyText2.merge(
                                          TextStyle(color: Theme.of(context).focusColor),
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).hintColor)),
                                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                                    labelStyle: Theme.of(context).textTheme.bodyText2.merge(
                                          TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                  )
                            ),
                            TextFormField(
                              controller:
                                  editDescCon,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .hintColor),
                              keyboardType:
                                  TextInputType.number,
                              decoration: InputDecoration(
                                    hintText: 'Description',
                                    labelText: "Description",
                                    hintStyle: Theme.of(context).textTheme.bodyText2.merge(
                                          TextStyle(color: Theme.of(context).focusColor),
                                        ),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).hintColor)),
                                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                                    labelStyle: Theme.of(context).textTheme.bodyText2.merge(
                                          TextStyle(color: Theme.of(context).hintColor),
                                        ),
                                  )
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          MaterialButton(
                            onPressed: () async {
                              snapshot.data[index].task=editTaskCon.text;
                              snapshot.data[index].desc=editDescCon.text;
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .accentColor),
                            ),
                          ),
                        ],
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                });
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal:20,vertical:8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Flexible(
                    child: Text(snapshot.data[index].task,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                  ),
                  Flexible(
                    child: Text(snapshot.data[index].date,
                    style: TextStyle(
                      fontSize: 17,
                      color:
                      (snapshot.data[index].date.compareTo(dateToday)<0.toInt())  //this is logic check if the date of task is passed or not
                      ?Colors.red:Colors.black,
                      fontWeight: FontWeight.w500)),
                  ),
                  Flexible(
                    child: IconButton(onPressed: (){
                      widget.bloc.onRemoveAction(snapshot.data[index]);
                      showSnack(context, 'Task Completed !!');
                    },
                icon: CircleAvatar(backgroundColor: Colors.green,child: Icon(Icons.done,color: Colors.white,)),),
                  ),
                ],),
              ),
            ),
          );
        },
      );
        },
      ), 
    );
  }
}


class TaskTextArea extends StatefulWidget{
  @override
  _TaskTextAreaState createState() => _TaskTextAreaState();
}

class _TaskTextAreaState extends State<TaskTextArea> {
  TextEditingController _controller= TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Flexible(
           flex: 2,
           child: Text('Task',
           style: TextStyle(
             fontSize: 18,
             color: Colors.black,
             fontWeight: FontWeight.bold
           ),
           ),
         ),
         Flexible(
           flex: 5,
           child: Container(
                      // height: height * 0.06,
                      child: TextFormField(
                        // focusNode: node,
                        controller: taskController,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        validator: (val) {
                          if (val.length<3)
                            return 'Not a proper task';
                          return null;
                        },
                        onChanged: (val) {
                          // email = val;
                        },
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xff31343E),
                          hintText: 'Enter Task Name',
                          hintStyle: TextStyle(
                            color: Color(0xff8E8E8E),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff1A1D2A),
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff6D6F76),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
         ), 
        ],
      ),
    );   
  }
}



class DescriptionArea extends StatefulWidget{
  @override
  _DescriptionAreaState createState() => _DescriptionAreaState();
}

class _DescriptionAreaState extends State<DescriptionArea> {
  TextEditingController _controller= TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Flexible(
           flex: 2,
           child: Text('Description',
           style: TextStyle(
             fontSize: 18,
             color: Colors.black,
             fontWeight: FontWeight.bold
           ),
           ),
         ),
         Flexible(
           flex: 5,
           child: Container(
                      // height: height * 0.06,
                      child: TextFormField(
                        // focusNode: node,
                        controller: descController,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        validator: (val) {
                          if (val.length<3)
                            return 'Not a proper description';
                          return null;
                        },
                        onChanged: (val) {
                          // email = val;
                        },
                        textAlign: TextAlign.start,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          // fillColor: Color(0xff31343E),
                          hintText: 'Describe your task ....',
                          hintStyle: TextStyle(
                            color: Color(0xff8E8E8E),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff1A1D2A),
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff6D6F76),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                    ),
         ), 
        ],
      ),
    );   
  }
}



class DeadlineArea extends StatefulWidget{
  @override
  _DeadlineAreaState createState() => _DeadlineAreaState();
}

class _DeadlineAreaState extends State<DeadlineArea> {
  TextEditingController _controller= TextEditingController();
  
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         Flexible(
           flex: 1,
           child: Text('Deadline :',
           style: TextStyle(
             fontSize: 18,
             color: Colors.black,
             fontWeight: FontWeight.bold
           ),
           ),
         ),
         Flexible(
           flex: 3,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
              //  Text('${date}',style: TextStyle(fontWeight: FontWeight.bold),),
               Container(
                 width: MediaQuery.of(context).size.width*0.6,
                 height: MediaQuery.of(context).size.height*0.05,
                 child: DateTimePicker(
                        type: DateTimePickerType.date,
                        dateMask: 'd MMM, yyyy',
                        initialValue: DateTime.now().toString(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        icon: Icon(Icons.event),
                        // dateLabelText: 'Date',
                        timeLabelText: "Hour",
                        textAlign: TextAlign.center,
                        selectableDayPredicate: (date) {
                          // Disable weekend days to select from the calendar
                          // if (date.weekday == 6 || date.weekday == 7) {
                          //   return false;
                          // }

                          return true;
                        },
                        onChanged: (val) => date=val,
                        validator: (val) {
                          print(val);
                          return null;
                        },
                        onSaved: (val) => print(val),
                      ),
               )
             ],
           )
         ), 
        ],
      ),
    );   
  }
}