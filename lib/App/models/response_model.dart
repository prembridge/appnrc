// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
  Welcome({
    this.response,
    this.messages,
  });

  Response response;
  List<Message> messages;

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        response: Response.fromJson(json["response"]),
        messages: List<Message>.from(
            json["messages"].map((x) => Message.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "response": response.toJson(),
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
      };
}

class Message {
  Message({
    this.code,
    this.message,
  });

  String code;
  String message;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        code: json["code"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
      };
}

class Response {
  Response({
    this.dataInfo,
    this.data,
  });

  DataInfo dataInfo;
  List<Datum> data;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        dataInfo: DataInfo.fromJson(json["dataInfo"]),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dataInfo": dataInfo.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  Datum({
    this.fieldData,
    this.portalData,
    this.recordId,
    this.modId,
  });

  FieldData fieldData;
  PortalData portalData;
  dynamic recordId;
  String modId;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        fieldData: FieldData.fromJson(json["fieldData"]),
        portalData: PortalData.fromJson(json["portalData"]),
        recordId: json["recordId"],
        modId: json["modId"],
      );

  Map<String, dynamic> toJson() => {
        "fieldData": fieldData.toJson(),
        "portalData": portalData.toJson(),
        "recordId": recordId,
        "modId": modId,
      };
}

class FieldData {
  FieldData({
    this.gatheringStatus,
    this.fullName,
    this.leader,
    this.yearOfStart,
    this.pin,
    this.unHabitation,
    this.habitation,
    this.village,
    this.colony,
    this.block,
    this.district,
    this.state,
    this.belAdded,
    this.averageAttendance,
    this.newBpt,
    this.reportingMonth,
    this.reportingYear,
    this.fkContactId,
    this.appContainerField1,
    this.recordId,
    this.foundCount,
  });

  String gatheringStatus;
  String fullName;
  String leader;
  dynamic yearOfStart;
  dynamic pin;
  String unHabitation;
  String habitation;
  String village;
  String colony;
  String block;
  String district;
  String state;
  dynamic belAdded;
  dynamic averageAttendance;
  dynamic newBpt;
  String reportingMonth;
  dynamic reportingYear;
  String fkContactId;
  String appContainerField1;
  dynamic recordId;
  String foundCount;

  factory FieldData.fromJson(Map<String, dynamic> json) => FieldData(
        gatheringStatus: json["Gathering_Status"],
        fullName: json["Full_Name"],
        leader: json["Leader"],
        yearOfStart: json["Year_of_Start"],
        pin: json["Pin"],
        unHabitation: json["Un_Habitation"],
        habitation: json["Habitation"],
        village: json["Village"],
        colony: json["Colony"],
        block: json["Block"],
        district: json["District"],
        state: json["State"],
        belAdded: json["Bel_Added"],
        averageAttendance: json["Average_Attendance"],
        newBpt: json["New_BPT"],
        reportingMonth: json["Reporting_Month"],
        reportingYear: json["Reporting_Year"],
        fkContactId: json["fk_Contact_Id"],
        appContainerField1: json["App_container_field1"],
        recordId: json["Record_id"],
        foundCount: json["Found_count"],
      );

  Map<String, dynamic> toJson() => {
        "Gathering_Status": gatheringStatus,
        "Full_Name": fullName,
        "Leader": leader,
        "Year_of_Start": yearOfStart,
        "Pin": pin,
        "Un_Habitation": unHabitation,
        "Habitation": habitation,
        "Village": village,
        "Colony": colony,
        "Block": block,
        "District": district,
        "State": state,
        "Bel_Added": belAdded,
        "Average_Attendance": averageAttendance,
        "New_BPT": newBpt,
        "Reporting_Month": reportingMonth,
        "Reporting_Year": reportingYear,
        "fk_Contact_Id": fkContactId,
        "App_container_field1": appContainerField1,
        "Record_id": recordId,
        "Found_count": foundCount,
      };
}

class PortalData {
  PortalData();

  factory PortalData.fromJson(Map<String, dynamic> json) => PortalData();

  Map<String, dynamic> toJson() => {};
}

class DataInfo {
  DataInfo({
    this.database,
    this.layout,
    this.table,
    this.totalRecordCount,
    this.foundCount,
    this.returnedCount,
  });

  String database;
  String layout;
  String table;
  dynamic totalRecordCount;
  dynamic foundCount;
  dynamic returnedCount;

  factory DataInfo.fromJson(Map<String, dynamic> json) => DataInfo(
        database: json["database"],
        layout: json["layout"],
        table: json["table"],
        totalRecordCount: json["totalRecordCount"],
        foundCount: json["foundCount"],
        returnedCount: json["returnedCount"],
      );

  Map<String, dynamic> toJson() => {
        "database": database,
        "layout": layout,
        "table": table,
        "totalRecordCount": totalRecordCount,
        "foundCount": foundCount,
        "returnedCount": returnedCount,
      };
}
