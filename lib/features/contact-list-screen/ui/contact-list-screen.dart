import 'package:flutter/material.dart';
import 'package:kontaku/core/utils/utils.dart';
import 'package:kontaku/core/widget/search_contacts_panel.dart';
import '../logic/func.dart';

Color borderColor = Color.fromARGB(255, 255, 230, 194);

class Contactlistscreen2 extends StatefulWidget {
  const Contactlistscreen2({super.key});

  @override
  State<Contactlistscreen2> createState() => _Contactlistscreen2State();
}

class _Contactlistscreen2State extends State<Contactlistscreen2> {
  TextEditingController _numberPhoneController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _numberPhoneController.text = "081234567890";
  }

  @override
  void dispose() {
    _numberPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isCompact = screenWidth < 380;
    final dialFieldBottom = isCompact ? 116.0 : 130.0;
    final actionBarBottom = isCompact ? 82.0 : 94.0;
    final searchTop = isCompact ? 24.0 : 40.0;

    final safeDialBottom = (dialFieldBottom - keyboardInset).clamp(
      0.0,
      dialFieldBottom,
    );
    final safeActionBottom = (actionBarBottom - keyboardInset).clamp(
      0.0,
      actionBarBottom,
    );

    final dialFieldWidth = isCompact
        ? Kontaku.vw(80, context)
        : Kontaku.vw(72, context);
    final dialFieldHeight = isCompact ? 48.0 : 52.0;
    final keypadWidth = isCompact
        ? Kontaku.vw(70, context)
        : Kontaku.vw(60, context);
    final keypadSpacing = isCompact ? 8.0 : 10.0;
    final numberButtonSize = isCompact ? 58.0 : 64.0;
    final numberFontSize = isCompact ? 22.0 : 24.0;

    final actionBarHeight = isCompact ? 76.0 : 84.0;
    final actionBarWidth = actionBarHeight * 2;
    final actionIconSize = isCompact ? 28.0 : 32.0;
    final addButtonOffset = isCompact ? -26.0 : -30.0;
    final addButtonSize = isCompact ? 52.0 : 56.0;

    return SafeArea(
      child: Container(
        width: Kontaku.vw(100, context),
        height: Kontaku.vh(100, context),
        color: Color(Kontaku.colors[3]),
        child: Stack(
          children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: safeDialBottom,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: dialFieldWidth,
                    height: dialFieldHeight,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 12 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1114),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _numberPhoneController,
                            keyboardType: TextInputType.phone,
                            readOnly: true,
                            showCursor: false,
                            enableInteractiveSelection: false,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 20 : 22,
                              fontWeight: FontWeight.w300,
                              height: 1,
                            ),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_numberPhoneController.text.isEmpty) {
                              return;
                            }
                            _numberPhoneController.text = _numberPhoneController
                                .text
                                .substring(
                                  0,
                                  _numberPhoneController.text.length - 1,
                                );
                            print('Delete button pressed');
                          },
                          icon: const Icon(
                            Icons.backspace,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: isCompact ? 34 : 40,
                            minHeight: isCompact ? 34 : 40,
                          ),
                          splashRadius: isCompact ? 18 : 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isCompact ? 10 : 12),
                  SizedBox(
                    width: keypadWidth,
                    child: GridView(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: keypadSpacing,
                        crossAxisSpacing: keypadSpacing,
                      ),
                      children: [
                        inputNumber("1", numberButtonSize, numberFontSize),
                        inputNumber("2", numberButtonSize, numberFontSize),
                        inputNumber("3", numberButtonSize, numberFontSize),
                        inputNumber("4", numberButtonSize, numberFontSize),
                        inputNumber("5", numberButtonSize, numberFontSize),
                        inputNumber("6", numberButtonSize, numberFontSize),
                        inputNumber("7", numberButtonSize, numberFontSize),
                        inputNumber("8", numberButtonSize, numberFontSize),
                        inputNumber("9", numberButtonSize, numberFontSize),
                        inputNumber("*", numberButtonSize, numberFontSize),
                        inputNumber("0", numberButtonSize, numberFontSize),
                        inputNumber("#", numberButtonSize, numberFontSize),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: safeActionBottom,
            child: Center(
              child: Container(
                padding: EdgeInsets.only(top: isCompact ? 26 : 30),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: actionBarWidth,
                      height: actionBarHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: Color(Kontaku.colors[1]),
                        border: Border.all(
                          color: borderColor, // Border color
                          width: 4.0, // Border width
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('Call button pressed');
                              },
                              child: SizedBox(
                                child: Icon(
                                  Icons.phone,
                                  color: Color(Kontaku.colors[3]),
                                  size: actionIconSize,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                print('Call button pressed');
                              },
                              child: SizedBox(
                                child: Icon(
                                  Icons.phone,
                                  color: Color(Kontaku.colors[3]),
                                  size: actionIconSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: addButtonOffset,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        width: addButtonSize,
                        height: addButtonSize,
                        child: FloatingActionButton(
                          elevation: 0,
                          backgroundColor: Color(Kontaku.colors[1]),
                          shape: const CircleBorder(
                            side: BorderSide(color: Colors.white, width: 4),
                          ),
                          onPressed: () {
                            addContact(
                              context,
                              number: _numberPhoneController.text,
                            );
                            print('Add contact button pressed');
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: isCompact ? 26 : 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            top: searchTop,
            child: SearchContactsPanel(),
          ),
          ],
        ),
      ),
    );
  }

  Container inputNumber(String number, double buttonSize, double fontSize) {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: buttonSize,
        height: buttonSize,
        child: ElevatedButton(
          onPressed: () {
            print('Number $number pressed');
            _numberPhoneController.text += number;
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Color(Kontaku.colors[1]),
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
            side: BorderSide(color: borderColor, width: 4.0),
          ),
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

