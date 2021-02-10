import 'package:Delivery/AppTheme.dart';
import 'package:Delivery/AppThemeNotifier.dart';
import 'package:Delivery/api/api_util.dart';
import 'package:Delivery/controllers/FavoriteController.dart';
import 'package:Delivery/models/Favorite.dart';
import 'package:Delivery/models/MyResponse.dart';
import 'package:Delivery/models/Product.dart';
import 'package:Delivery/services/AppLocalizations.dart';
import 'package:Delivery/utils/ColorUtils.dart';
import 'package:Delivery/utils/Generator.dart';
import 'package:Delivery/utils/SizeConfig.dart';
import 'package:Delivery/views/ProductScreen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import 'LoadingScreens.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  //Theme Data
  ThemeData themeData;
  CustomAppTheme customAppTheme;

  //Global Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  //Other Variables
  bool isInProgress = false;
  List<Favorite> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadFavoriteProducts() async {
    if (mounted) {
      setState(() {
        isInProgress = true;
      });
    }

    MyResponse<List<Favorite>> myResponse =
        await FavoriteController.getAllFavorite();

    if (myResponse.success) {
      favorites = myResponse.data;
    } else {
      ApiUtil.checkRedirectNavigation(context, myResponse.responseCode);
      showMessage(message: myResponse.errorText);
    }

    if (mounted) {
      setState(() {
        isInProgress = false;
      });
    }
  }

  Future<void> _refresh() async {
    _loadFavoriteProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeNotifier>(
      builder: (BuildContext context, AppThemeNotifier value, Widget child) {
        int themeType = value.themeMode();
        themeData = AppTheme.getThemeFromThemeMode(themeType);
        customAppTheme = AppTheme.getCustomAppTheme(themeType);
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeFromThemeMode(value.themeMode()),
            home: Scaffold(
                backgroundColor: customAppTheme.bgLayer1,
                key: _scaffoldKey,
                appBar: AppBar(
                  backgroundColor: customAppTheme.bgLayer1,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(Translator.translate("favorites"),
                      style: AppTheme.getTextStyle(
                          themeData.appBarTheme.textTheme.headline6,
                          fontWeight: 600)),
                ),
                body: RefreshIndicator(
                  onRefresh: _refresh,
                  backgroundColor: customAppTheme.bgLayer1,
                  color: themeData.colorScheme.primary,
                  key: _refreshIndicatorKey,
                  child: ListView(
                    padding: Spacing.zero,
                    children: [
                      Container(
                        height: MySize.size3,
                        child: isInProgress
                            ? LinearProgressIndicator(
                                minHeight: MySize.size3,
                              )
                            : Container(
                                height: MySize.size3,
                              ),
                      ),
                      _buildBody()
                    ],
                  ),
                )));
      },
    );
  }

  Widget _buildBody() {
    if (favorites.length != 0) {
      return Container(child: _showProducts(favorites));
    } else if (isInProgress) {
      return Container(
          child: LoadingScreens.getFavouriteLoadingScreen(
              context, themeData, customAppTheme,
              itemCount: 5));
    } else {
      return Center(
        child: Text(
          Translator.translate("you_have_not_favorite_item_yet"),
          style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
              color: themeData.colorScheme.onBackground, fontWeight: 500),
        ),
      );
    }
  }

  Widget _showProducts(List<Favorite> favorites) {
    List<Widget> listWidgets = [];

    for (Favorite favorite in favorites) {
      listWidgets.add(InkWell(
        onTap: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProductScreen(
                        productId: favorite.product.id,
                      )));
          _refresh();
        },
        child: Container(
          margin: Spacing.bottom(16),
          child: _singleProduct(favorite.product),
        ),
      ));
    }

    return Container(
      margin: Spacing.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: listWidgets,
      ),
    );
  }

  _singleProduct(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: customAppTheme.bgLayer1,
        borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
        border: Border.all(color: customAppTheme.bgLayer4),
        boxShadow: [
          BoxShadow(
            color: customAppTheme.shadowColor,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(MySize.size16),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(MySize.size8)),
            child: product.productImages.length != 0
                ? Image.network(
                    product.productImages[0].url,
                    loadingBuilder: (BuildContext ctx, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return LoadingScreens.getSimpleImageScreen(
                            context, themeData, customAppTheme,
                            width: MySize.size90, height: MySize.size90);
                      }
                    },
                    height: MySize.size90,
                    width: MySize.size90,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    Product.getPlaceholderImage(),
                    height: MySize.size90,
                    fit: BoxFit.fill,
                  ),
          ),
          Expanded(
            child: Container(
              height: MySize.size90,
              margin: EdgeInsets.only(left: MySize.size16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTheme.getTextStyle(
                              themeData.textTheme.subtitle2,
                              fontWeight: 600,
                              letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        product.isFavorite
                            ? MdiIcons.heart
                            : MdiIcons.heartOutline,
                        color: product.isFavorite
                            ? themeData.colorScheme.primary
                            : themeData.colorScheme.onBackground.withAlpha(100),
                        size: 22,
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Generator.buildRatingStar(
                          rating: product.rating,
                          activeColor: ColorUtils.getColorFromRating(
                              product.rating.ceil(), customAppTheme, themeData),
                          size: MySize.size16,
                          inactiveColor: themeData.colorScheme.onBackground),
                      Container(
                        margin: EdgeInsets.only(left: MySize.size4),
                        child: Text("(" + product.totalRating.toString() + ")",
                            style: AppTheme.getTextStyle(
                                themeData.textTheme.bodyText1,
                                fontWeight: 600)),
                      ),
                    ],
                  ),
                  Text(
                    product.productItems.length.toString() +
                        " " +
                        Translator.translate("options_available"),
                    style: AppTheme.getTextStyle(themeData.textTheme.bodyText2,
                        fontWeight: 500),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showMessage({String message = "Something wrong", Duration duration}) {
    if (duration == null) {
      duration = Duration(seconds: 3);
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(message,
            style: AppTheme.getTextStyle(themeData.textTheme.subtitle2,
                letterSpacing: 0.4, color: themeData.colorScheme.onPrimary)),
        backgroundColor: themeData.colorScheme.primary,
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }
}
