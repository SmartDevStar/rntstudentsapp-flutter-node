import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:rnt_app/utils/utils.dart';

class RecordedClassListItem extends StatefulWidget {
  const RecordedClassListItem({ 
    super.key, 
    this.sessionRecodingWebLink,
    this.classStartDate,
    this.recordDuration,
    this.labelColor,
    this.dataColor,
    this.icon,
    this.svgIcon,
  });

  final String? sessionRecodingWebLink;
  final String? classStartDate;
  final int? recordDuration;
  final Color? labelColor;
  final Color? dataColor;
  final IconData? icon;
  final String? svgIcon;

  @override
  State<RecordedClassListItem> createState() => _RecordedClassListItemState();
}

class _RecordedClassListItemState extends State<RecordedClassListItem> {

  void _getMetadata(String url) async {
    print(url);
    bool _isValid = _getUrlValid(url);
    if (_isValid) {
      Metadata? _metadata = await AnyLinkPreview.getMetadata(
        link: url,
        cache: Duration(days: 7),
        proxyUrl: "https://cors-anywhere.herokuapp.com/", // Needed for web app
      );
      debugPrint(_metadata?.title);
      debugPrint(_metadata?.desc);
    } else {
      debugPrint("URL is not valid");
    }
  }

  bool _getUrlValid(String url) {
    bool _isUrlValid = AnyLinkPreview.isValidLink(
      url,
      protocols: ['http', 'https'],
      hostWhitelist: ['https://youtube.com/'],
      hostBlacklist: ['https://facebook.com/'],
    );
    return _isUrlValid;
  }

  @override
  void initState() {
    super.initState();
    _getMetadata(widget.sessionRecodingWebLink!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xFF333F50),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 170,
              height: 110,
              child: AnyLinkPreview(
                link: widget.sessionRecodingWebLink ?? "",
                displayDirection: UIDirection.uiDirectionHorizontal,
                showMultimedia: true,
                borderRadius: 0.0,
                bodyMaxLines: 1,
                bodyTextOverflow: TextOverflow.ellipsis,
                titleStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                bodyStyle: const TextStyle(color: Colors.grey, fontSize: 12),
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
                          convertDateTimeFormat(widget.classStartDate ?? DateTime.now().toString(), ""),
                          style: TextStyle(
                            color: widget.dataColor,
                            fontFamily: 'Roboto',
                            fontSize: 18,
                          ),
                        ), 
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: IconTheme(
                          data: IconThemeData(
                            color: widget.labelColor,
                            size: 30,
                          ),
                          child: widget.svgIcon == null || widget.svgIcon!.isEmpty
                              ? Icon(widget.icon)
                              : SvgPicture.asset(
                            widget.svgIcon!,
                            width: 30,
                            height: 30,
                            colorFilter: ColorFilter.mode(widget.labelColor!, BlendMode.srcIn),
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
                          convertToTime(widget.recordDuration!),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 17,
                              color: widget.dataColor,
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
      );
  }
}