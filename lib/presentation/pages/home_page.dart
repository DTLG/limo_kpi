import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import 'failure_chart_page.dart';
import 'all_failures_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'deformat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Lottie.asset(
                    'assets/lottiefiles/main_screen.json',
                  ),
                ),
                Text(
                  'Limo-KPI',
                  style: GoogleFonts.roboto(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryButtonColor,
                    letterSpacing: 2.0,
                    // shadows: [
                    //   Shadow(
                    //     color: AppColors.primaryButtonColor.withOpacity(0.3),
                    //     offset: const Offset(3, 3),
                    //     blurRadius: 5,
                    //   ),
                    // ],
                    decoration: TextDecoration.none,
                    decorationThickness: 2,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                const Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 58, 143, 183)
                                .withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: AppColors.primaryButtonTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FailureChartPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Аналіз простоїв',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 58, 143, 183)
                                .withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: AppColors.primaryButtonTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AllFailuresPage.allFailures(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Всі простої',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 58, 143, 183)
                                .withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryButtonColor,
                          foregroundColor: AppColors.primaryButtonTextColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DeformatPage(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Деформат',
                              style: GoogleFonts.roboto(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text(
                        'Limo-KPI',
                        style: GoogleFonts.roboto(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryButtonColor,
                          letterSpacing: 2.0,
                          // shadows: [
                          //   Shadow(
                          //     color: AppColors.primaryButtonColor.withOpacity(0.3),
                          //     offset: const Offset(3, 3),
                          //     blurRadius: 5,
                          //   ),
                          // ],
                          decoration: TextDecoration.none,
                          decorationThickness: 2,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Lottie.asset(
                          'assets/lottiefiles/main_screen.json',
                          // width: MediaQuery.of(context).size.width * 0.8,
                          // height: MediaQuery.of(context).size.height * 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Spacer(),
                    const Spacer(),
                    Column(
                      children: [
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 58, 143, 183)
                                    .withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButtonColor,
                              foregroundColor: AppColors.primaryButtonTextColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const FailureChartPage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Аналіз простоїв',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 58, 143, 183)
                                    .withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButtonColor,
                              foregroundColor: AppColors.primaryButtonTextColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AllFailuresPage.allFailures(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Всі простої',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 58, 143, 183)
                                    .withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryButtonColor,
                              foregroundColor: AppColors.primaryButtonTextColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DeformatPage(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Деформат',
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
