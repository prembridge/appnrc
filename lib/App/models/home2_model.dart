class FieldDataModel {
  FieldData fieldData;
  String recordId;
  String modId;

  FieldDataModel({this.fieldData, this.recordId, this.modId});

  FieldDataModel.fromJson(Map<String, dynamic> json) {
    fieldData = json['fieldData'] != null
        ? new FieldData.fromJson(json['fieldData'])
        : null;
    recordId = json['recordId'];
    modId = json['modId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fieldData != null) {
      data['fieldData'] = this.fieldData.toJson();
    }
    data['recordId'] = this.recordId;
    data['modId'] = this.modId;
    return data;
  }
}

class FieldData {
  String locationId;
  String fkUniqueId;
  String fullName;
  String leaderName;
  String gathering;
  String unHabbitation;
  String village;
  String colony;
  String block;
  String district;
  String state;
  String gatheringImage;
  String familyImage;
  String leaderImage;
  String communityImage;
  String vCHU;
  String location;
  String status;

  FieldData(
      {this.locationId,
      this.fkUniqueId,
      this.fullName,
      this.leaderName,
      this.gathering,
      this.unHabbitation,
      this.village,
      this.colony,
      this.block,
      this.district,
      this.state,
      this.gatheringImage,
      this.familyImage,
      this.leaderImage,
      this.communityImage,
      this.vCHU,
      this.location,
      this.status});

  FieldData.fromJson(Map<String, dynamic> json) {
    locationId = json['Location_id'];
    fkUniqueId = json['Fk_unique_id'];
    fullName = json['Full_name'];
    leaderName = json['Leader_name'];
    gathering = json['Gathering'];
    unHabbitation = json['Un_habbitation'];
    village = json['Village'];
    colony = json['Colony'];
    block = json['Block'];
    district = json['District'];
    state = json['State'];
    gatheringImage = json['Gathering_image'];
    familyImage = json['Family_image'];
    leaderImage = json['Leader_image'];
    communityImage = json['Community_image'];
    vCHU = json['VCHU'];
    location = json['Location'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Location_id'] = this.locationId;
    data['Fk_unique_id'] = this.fkUniqueId;
    data['Full_name'] = this.fullName;
    data['Leader_name'] = this.leaderName;
    data['Gathering'] = this.gathering;
    data['Un_habbitation'] = this.unHabbitation;
    data['Village'] = this.village;
    data['Colony'] = this.colony;
    data['Block'] = this.block;
    data['District'] = this.district;
    data['State'] = this.state;
    data['Gathering_image'] = this.gatheringImage;
    data['Family_image'] = this.familyImage;
    data['Leader_image'] = this.leaderImage;
    data['Community_image'] = this.communityImage;
    data['VCHU'] = this.vCHU;
    data['Location'] = this.location;
    data['status'] = this.status;
    return data;
  }
}
