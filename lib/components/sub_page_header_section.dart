import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rnt_app/utils/consts.dart';

class SubPageHeaderSection extends StatelessWidget {
  const SubPageHeaderSection({
    super.key,
    this.headerType = SubPageHeaderType.normal,
    this.onTap,
    this.title,
    this.avatarAddress,
    this.courseName,
    this.courseCode,
    this.teacherName,
    this.courseUnits,
    this.icon = Icons.home,
    this.svgIcon,
    this.isRotate = false,
    this.avatarImage,
    this.labelColor = const Color(0xFF8497B0),
    this.dataColor = const Color(0xFFFFFFFF),
    this.onHeaderIconClicked,
    this.onAddClass,
    this.onClickSendMsgToALlStudents,
  });

  final SubPageHeaderType headerType;
  final String? title;
  final String? avatarAddress;
  final String? courseName;
  final String? courseCode;
  final String? teacherName;
  final int? courseUnits;
  final IconData icon;
  final String? svgIcon;
  final bool isRotate;
  final Color labelColor;
  final Color dataColor;
  final File? avatarImage;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onHeaderIconClicked;
  final GestureTapCallback? onAddClass;
  final GestureTapCallback? onClickSendMsgToALlStudents;

  @override
  Widget build(BuildContext context) {
    return headerType == SubPageHeaderType.normal
        ? _buildNormalHeader()
        : headerType == SubPageHeaderType.profile
            ? _buildProfileHeader()
            : headerType == SubPageHeaderType.courseDetail
                ? _buildCourseDetailHeader()
                : headerType == SubPageHeaderType.myClassSchedule ||
                        headerType == SubPageHeaderType.addClass
                    ? _buildMyClassScheduleHeader()
                    : headerType == SubPageHeaderType.studyResources
                        ? _buildStudyResourcesHeader()
                        : headerType == SubPageHeaderType.studentsList
                            ? _buildStudentsListHeader()
                            : Container();
  }

  Widget _buildNormalHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, right: 20, bottom: 15),
        color: const Color(0xFF222A35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13),
                child: Text(
                  title!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    color: labelColor,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onHeaderIconClicked,
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconTheme(
                  data: IconThemeData(
                    color: labelColor,
                    size: 50,
                  ),
                  child: isRotate
                      ? Transform.rotate(
                          angle: 25 * 3.14 / 180,
                          child: svgIcon == null || svgIcon!.isEmpty
                              ? Icon(icon)
                              : SvgPicture.asset(
                                  svgIcon!,
                                  width: 50,
                                  height: 50,
                                  colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                                ),
                        )
                      : svgIcon == null || svgIcon!.isEmpty
                          ? Icon(icon)
                          : SvgPicture.asset(
                              svgIcon!,
                              width: 50,
                              height: 50,
                              colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 7.0, right: 20, bottom: 7.0),
        color: const Color(0xFF222A35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 13, right: 7.0),
                child: Text(
                  title!,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 23,
                    color: labelColor,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: onHeaderIconClicked,
              child: avatarImage == null
                  ? avatarAddress!.isEmpty
                      ? IconTheme(
                          data: IconThemeData(
                            color: labelColor,
                            size: 25,
                          ),
                          child: const Icon(Icons.person))
                      : CircleAvatar(
                          backgroundImage: NetworkImage(avatarAddress!),
                          radius: 25,
                        )
                  : CircleAvatar(
                      backgroundImage: FileImage(avatarImage!),
                      radius: 25,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDetailHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, right: 20, bottom: 5),
        color: const Color(0xFF222A35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Text(
                    title!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      color: labelColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        courseName!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          color: dataColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        ":نام درس",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 17,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        courseCode!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 16,
                            color: dataColor,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        ":کد درس",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 17,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        teacherName ?? "",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          color: dataColor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        ":مدرس",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 17,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        courseUnits!.toString(),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 16,
                            color: dataColor,
                            fontFamily: 'Roboto'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        ":تعداد واحد",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 17,
                          color: labelColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 50,
                ),
                child: isRotate
                    ? Transform.rotate(
                        angle: 25 * 3.14 / 180,
                        child: svgIcon == null || svgIcon!.isEmpty
                            ? Icon(icon)
                            : SvgPicture.asset(
                                svgIcon!,
                                width: 50,
                                height: 50,
                                colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                              ),
                      )
                    : svgIcon == null || svgIcon!.isEmpty
                        ? Icon(icon)
                        : SvgPicture.asset(
                            svgIcon!,
                            width: 50,
                            height: 50,
                            colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyClassScheduleHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, right: 20, bottom: 10),
        color: const Color(0xFF222A35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onAddClass,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: IconTheme(
                      data: IconThemeData(
                        color: labelColor,
                        size: 50,
                      ),
                      child: SvgPicture.asset(
                        "assets/images/plus.svg",
                        width: 50,
                        height: 50,
                        colorFilter: headerType == SubPageHeaderType.myClassSchedule
                        ? const ColorFilter.mode(Colors.green, BlendMode.srcIn)
                        : ColorFilter.mode(labelColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: headerType == SubPageHeaderType.addClass
                              ? const EdgeInsets.only(top: 8)
                              : const EdgeInsets.only(top: 3),
                          child: Text(
                            title!,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 23,
                              color: headerType == SubPageHeaderType.addClass
                                  ? labelColor
                                  : dataColor,
                            ),
                          ),
                        ),
                        if (headerType == SubPageHeaderType.addClass)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              courseName!,
                              textAlign: TextAlign.right,
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
                    padding: const EdgeInsets.only(left: 10.0),
                    child: IconTheme(
                      data: IconThemeData(
                        color: labelColor,
                        size: 50,
                      ),
                      child: isRotate
                          ? Transform.rotate(
                              angle: 25 * 3.14 / 180,
                              child: svgIcon == null || svgIcon!.isEmpty
                                  ? Icon(icon)
                                  : SvgPicture.asset(
                                      svgIcon!,
                                      width: 50,
                                      height: 50,
                                      colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                                    ),
                            )
                          : svgIcon == null || svgIcon!.isEmpty
                              ? Icon(icon)
                              : SvgPicture.asset(
                                  svgIcon!,
                                  width: 50,
                                  height: 50,
                                  colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyResourcesHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, right: 20, bottom: 5),
        color: const Color(0xFF222A35),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Text(
                    title!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      color: labelColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Text(
                        courseName!,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          color: dataColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconTheme(
                data: IconThemeData(
                  color: labelColor,
                  size: 50,
                ),
                child: isRotate
                    ? Transform.rotate(
                        angle: 25 * 3.14 / 180,
                        child: svgIcon == null || svgIcon!.isEmpty
                            ? Icon(icon)
                            : SvgPicture.asset(
                                svgIcon!,
                                width: 50,
                                height: 50,
                                colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                              ),
                      )
                    : svgIcon == null || svgIcon!.isEmpty
                        ? Icon(icon)
                        : SvgPicture.asset(
                            svgIcon!,
                            width: 50,
                            height: 50,
                            colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsListHeader() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(top: 0.0, left: 0, right: 20, bottom: 6),
        color: const Color(0xFF222A35),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onClickSendMsgToALlStudents,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, right: 20),
                      child: SvgPicture.asset(
                        "assets/images/message.svg",
                        width: 50,
                        height: 50,
                        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      "پیغام به دانشحویان من",
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 13),
                  child: Text(
                    title!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 23,
                      color: labelColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: IconTheme(
                    data: IconThemeData(
                      color: labelColor,
                      size: 50,
                    ),
                    child: isRotate
                        ? Transform.rotate(
                            angle: 25 * 3.14 / 180,
                            child: svgIcon == null || svgIcon!.isEmpty
                                ? Icon(icon)
                                : SvgPicture.asset(
                                    svgIcon!,
                                    width: 50,
                                    height: 50,
                                    colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                                  ),
                          )
                        : svgIcon == null || svgIcon!.isEmpty
                            ? Icon(icon)
                            : SvgPicture.asset(
                                svgIcon!,
                                width: 50,
                                height: 50,
                                colorFilter: ColorFilter.mode(labelColor, BlendMode.srcIn),
                              ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
