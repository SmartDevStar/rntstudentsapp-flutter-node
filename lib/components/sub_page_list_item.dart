import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:rnt_app/utils/consts.dart';
import 'package:rnt_app/utils/utils.dart';

class SubPageListItem extends StatelessWidget {

  const SubPageListItem(
      { super.key,
        this.onTap,
        this.title,
        this.courseName,
        this.icon,
        this.svgIcon,
        this.subListType,
        this.classStartDate,
        this.classStateId,
        this.classStateDescription,
        this.publisher,
        this.studentEmail,
        this.studentContactNo,
        this.studentAvatar,
        this.recordClassScreen,
        this.recordDuration,
        this.notificationDate,
        this.notificationMessage,
        this.transactionDate,
        this.soaType,
        this.netTotalAmount,
        this.messageDate,
        this.messageContent,
        this.messageSender,
        this.labelColor,
        this.dataColor,
        this.fontSize,
        this.iconColor,
        this.onLinkRecordClass,
        this.onJoinClass,
      });

  final String? title;
  final String? courseName;
  final IconData? icon;
  final String? svgIcon;
  final GestureTapCallback? onTap;
  final SubPageListType? subListType;
  final String? classStartDate;
  final int? classStateId;
  final String? classStateDescription;
  final String? publisher;
  final String? studentEmail;
  final String? studentContactNo;
  final String? studentAvatar;
  final String? recordClassScreen;
  final int? recordDuration;
  final String? notificationDate;
  final String? notificationMessage;
  final String? transactionDate;
  final String? soaType;
  final dynamic netTotalAmount;
  final String? messageDate;
  final String? messageContent;
  final String? messageSender;
  final Color? labelColor;
  final Color? dataColor;
  final int? fontSize;
  final Color? iconColor;
  final GestureTapCallback? onLinkRecordClass;
  final GestureTapCallback? onJoinClass;

  @override
  Widget build(BuildContext context) {
    return subListType == SubPageListType.normal
        ? _buildNormalListItem()
        : subListType == SubPageListType.myCourses
        ? _buildMyCoursesListItem()
        : subListType == SubPageListType.classSchedule || subListType == SubPageListType.todayClasses
        ? _buildClassScheduleListItem()
        : subListType == SubPageListType.studyResources
        ? _buildStudyResources()
        : subListType == SubPageListType.studentsList
        ? _buildStudentsListItem()
        : subListType == SubPageListType.recordedClasses
        ? _buildRecordClassListItem()
        : subListType == SubPageListType.joinClass
        ? _buildJoinClassListItem()
        : subListType == SubPageListType.chatMessage
        ? _buildChatWithUsListItem()
        : subListType == SubPageListType.financialStatement
        ? _buildFinancialStatementItem()
        : Container();
  }

  _buildNormalListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        color: labelColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? Icon(icon)
                    : SvgPicture.asset(
                  svgIcon!,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(labelColor!, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildMyCoursesListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child:Padding(
                padding: EdgeInsets.zero,
                child: Text(
                  courseName!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: dataColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? Icon(icon)
                    : SvgPicture.asset(
                  svgIcon!,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(labelColor!, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildClassScheduleListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      subListType == SubPageListType.todayClasses
                          ? convertDateTimeFormat(classStartDate!, "time")
                          : convertDateTimeFormat(classStartDate!, "full"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: dataColor,
                          fontFamily: 'Roboto'
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      classStateDescription!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorOfClassStates[classStateId!],
                      ),
                    ),
                  ),
                  if(subListType == SubPageListType.todayClasses)
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                      child: ElevatedButton(
                        onPressed: onJoinClass,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: 40.0,
                          width: 110,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(0.0),
                              color: const Color(0xffffc000)),
                          padding: const EdgeInsets.all(0),
                          child: const Text(
                              "ورود",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              )
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? Icon(icon)
                    : SvgPicture.asset(
                  svgIcon!,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(labelColor!, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildStudyResources() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      publisher!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? Icon(icon)
                    : SvgPicture.asset(
                  svgIcon!,
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(labelColor!, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildStudentsListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      studentEmail!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      studentContactNo!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Roboto',
                        color: dataColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.zero,
                child: studentAvatar!.isEmpty
                    ? IconTheme(
                        data: IconThemeData(
                          color: labelColor,
                          size: 50,
                        ),
                        child: const Icon(Icons.person)
                      )
                    : CircleAvatar(
                  backgroundImage: NetworkImage(studentAvatar!),
                  radius: 25,
                ),
            ),
          ],
        ),
      ),
    );
  }
  _buildRecordClassListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.zero,
              child: GestureDetector(
                onTap: onLinkRecordClass,
                child: Image.asset(
                  recordClassScreen!,
                  width: 170,
                  height: 110,
                ),
              ),
            ),
            Expanded(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 15.0),
                        child: Text(
                          convertDateTimeFormat(classStartDate ?? DateTime.now().toString(), ""),
                          style: TextStyle(
                            color: dataColor,
                            fontFamily: 'Roboto',
                            fontSize: 18,
                          ),
                        ), 
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: IconTheme(
                          data: IconThemeData(
                            color: labelColor,
                            size: 30,
                          ),
                          child: svgIcon == null || svgIcon!.isEmpty
                              ? Icon(icon)
                              : SvgPicture.asset(
                            svgIcon!,
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(labelColor!, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5, left: 10),
                        child: Text(
                          convertToTime(recordDuration!),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 17,
                              color: dataColor,
                              fontFamily: 'Roboto'
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildJoinClassListItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      classStartDate!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        color: Color(0xFF8497B0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        color: Color(0xFF8497B0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      classStateDescription!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 21,
                        color: colorOfClassStates[classStateId!],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 3),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        height: 40.0,
                        width: 110,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0.0),
                            color: const Color(0xffffc000)),
                        padding: const EdgeInsets.all(0),
                        child: const Text(
                          "ورود",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 18,),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: const IconThemeData(
                  color: Color(0xFF8497B0),
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? Icon(icon)
                    : SvgPicture.asset(
                  svgIcon!,
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(Color(0xFF8497B0), BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _buildChatWithUsListItem() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 2,),
      color: const Color(0xFF333F50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
              padding: EdgeInsets.zero,
              child: Text(
                messageDate!,
                textAlign: TextAlign.right,
                style: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontFamily: "Roboto"
                ),
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    messageContent!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: dataColor,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                    ),
                  )
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 3, bottom: 0),
                  child: Text(
                    ": $messageSender",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: labelColor,
                        fontSize: 16
                    ),
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }
  _buildFinancialStatementItem() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child:Column(
                children: [
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(transactionDate!)),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: dataColor,
                          fontFamily: 'Roboto'
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      soaType!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: dataColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: Text(
                      "${netTotalAmount!}یورو",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 17,
                          color: dataColor,
                          fontFamily: 'Roboto'
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.zero,
              child: IconTheme(
                data: const IconThemeData(
                  color: Colors.lightGreen,
                  size: 30,
                ),
                child: svgIcon == null || svgIcon!.isEmpty
                    ? const Icon(Icons.money)
                    : SvgPicture.asset(
                  "assets/images/money.svg",
                  width: 30,
                  height: 30,
                  colorFilter: const ColorFilter.mode(Colors.lightGreen, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}