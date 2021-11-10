import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_app/models/artist.dart';
import 'package:service_app/models/category.dart';
import 'package:service_app/providers/auth.dart';
import 'package:service_app/providers/customer.dart';
import 'package:service_app/screens/set_location_screen.dart';

import '../Global.dart';

class EditArtistProfileScreen extends StatefulWidget {
  static const routeName = '/edit-artist-profile-screen';
  final String categoryId;
  final String categoryName;
  final String name;
  final String city;
  final String country;
  final double longi;
  final double lati;
  final String rate;
  final String bio;
  final String description;
  final String location;
  const EditArtistProfileScreen({
    Key key,
    this.categoryId,
    this.categoryName,
    this.bio,
    this.city,
    this.country,
    this.description,
    this.longi,
    this.lati,
    this.name,
    this.rate,
    this.location,
  }) : super(key: key);

  @override
  _EditArtistProfileScreenState createState() => _EditArtistProfileScreenState();
}

class _EditArtistProfileScreenState extends State<EditArtistProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _locationController = TextEditingController();
  bool isInit = true;
  String _catName = 'Select Category';
  Artist newArtist = Artist();

  Future<void> _showSubCategoryDialog(List<Category> subCategories) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Subcategories list:'),
            content: setupAlertDialoadContainer(subCategories),
          );
        });
  }

  Widget setupAlertDialoadContainer(List<Category> subCategories) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      width: MediaQuery.of(context).size.width / 2,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: subCategories.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              setState(() {
                _catName = subCategories[index].name;
                newArtist.categoryId = subCategories[index].id;
              });
              Provider.of<Customer>(context, listen: false).filterByCategories(subCategories[index].id);
              Navigator.pop(context);
            },
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(subCategories[index].name),
                Container(child: Image.network(subCategories[index].image), height: 50,),
              ],
            ),
          );
        },
      ),
    );
  }
/*
  Future<void> _showSubCategoryDialog(List<Category> subCategories) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        title: Text('Select Subcategory'),
        content: Container(
          height: MediaQuery.of(context).size.height / 2,
          child: ListView.builder(
            itemCount: subCategories != null ? subCategories.length : 0,
            itemBuilder: (ctx, i) {
              return Card(
                child: Text(
                  subCategories[i].name,
                ),
              );

              /*Column(
                children: [

                  /*
                  ListTile(
                    onTap: () {
                      setState(() {
                        _catName = subCategories[i].name;
                        newArtist.categoryId = subCategories[i].id;
                      });
                      Provider.of<Customer>(context, listen: false).filterByCategories(subCategories[i].id);
                      Navigator.pop(context);
                    },
                    title: Text(
                      subCategories[i].name,
                    ),
                  ),*/
                  Divider(),
                ],
              );*/
            },
          ),
        ),
      ),
    );
  }
*/
  Future<void> _showErrorDialog(String message) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Service App'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  showLoadingDialog(BuildContext ctx) {
    showDialog(
      barrierDismissible: false,
      context: ctx,
      builder: (BuildContext context) {
        return AlertDialog(
          content: new Row(
            children: [
              CircularProgressIndicator(),
              Container(
                margin: EdgeInsets.only(left: 7),
                child: Text("Please Wait..."),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    if (newArtist.categoryId == null || newArtist.categoryId.isEmpty) {
      newArtist..categoryId = widget.categoryId;
    }
    if (newArtist.location == null || newArtist.location.isEmpty) {
      newArtist..location = widget.location ?? '';
      newArtist..latitude = widget.lati != null ? widget.lati.toString() : '';
      newArtist..longitude = widget.longi != null ? widget.longi.toString() : '';
    }
    _formKey.currentState.save();

    try {
      Provider.of<Auth>(context, listen: false).updateArtistInfo(newArtist);
    } catch (err) {
      _showErrorDialog(err).then((value) => Navigator.of(context).pop());
    }
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      _locationController..text = widget.location;
      _catName = widget.categoryName ?? '';
      Provider.of<Customer>(context, listen: false).getAllCategories().then((value) {
        isInit = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<Customer>(context).categories;
    final subCategories = Provider.of<Customer>(context).subCategoriesList;
    return Builder(
      builder: (ctx) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Edit Personal Information'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 8.0,
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          return DraggableScrollableSheet(
                            expand: false,
                            builder: (ctx, controller) => Container(
                              child: ListView.builder(
                                controller: controller,
                                itemCount: categories != null ? categories.length : 0,
                                itemBuilder: (ctx, i) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          if (categories[i].subCategories > 0) {
                                            await Provider.of<Customer>(context, listen: false).getSubCategories(categories[i].id).then((value) async {
                                              await _showSubCategoryDialog(Global.subCats);
                                            });
                                          } else {
                                            setState(() {
                                              _catName = categories[i].name;
                                              newArtist.categoryId = categories[i].id;
                                            });
                                            Provider.of<Customer>(context, listen: false).filterByCategories(categories[i].id);
                                          }
                                          Navigator.pop(context);
                                        },
                                        title: Text(
                                          categories[i].name,
                                        ),
                                        trailing: Container(child: Image.network(categories[i].image), height: 40,),
                                      ),
                                      Divider(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    leading: Icon(Icons.collections_bookmark),
                    trailing: Icon(Icons.collections_bookmark),
                    title: Text(
                      _catName,
                      style: Theme.of(context).appBarTheme.textTheme.headline6.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (ctx) => SetLocationScreen(
                            lati: widget.lati,
                            longi: widget.longi,
                          ),
                        ),
                      )
                          .then((value) {
                        List<String> values = value;
                        _locationController..text = values[0];
                        newArtist..location = values[0];
                        newArtist..latitude = values[1];
                        newArtist..longitude = values[2];
                      });
                    },
                    child: TextFormField(
                      controller: _locationController,
                      enabled: false,
                      onSaved: (value) {
                        newArtist..location = value;
                      },
                      maxLines: 1,
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on),
                        labelText: 'Your Location',
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Invalid Name!';
                            }
                          },
                          onSaved: (value) {
                            newArtist..name = value;
                          },
                          maxLines: 1,
                          initialValue: widget.name ?? '',
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required field!';
                            }
                          },
                          onSaved: (value) {
                            newArtist..city = value;
                          },
                          maxLines: 1,
                          initialValue: widget.city ?? '',
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Your City',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required field!';
                            }
                          },
                          onSaved: (value) {
                            newArtist..country = value;
                          },
                          maxLines: 1,
                          initialValue: widget.country ?? '',
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Your Country',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required field!';
                            }
                          },
                          onSaved: (value) {
                            newArtist.price = value;
                          },
                          maxLines: 1,
                          initialValue: widget.rate ?? '',
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Your Rate',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required Field!';
                            }
                          },
                          onSaved: (value) {
                            newArtist..bio = value;
                          },
                          maxLines: 1,
                          maxLength: 40,
                          initialValue: widget.bio ?? '',
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Your Bio',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Required field!';
                            }
                          },
                          onSaved: (value) {
                            newArtist.aboutUs = value;
                          },
                          maxLines: 3,
                          initialValue: widget.description ?? '',
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                            labelText: 'Write A Description',
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: RaisedButton(
                          child: Center(
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                'Submit',
                                style: Theme.of(context).textTheme.headline6.copyWith(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                          ),
                          onPressed: () {
                            _submit().then(
                              (value) => Navigator.of(context).pop(),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).primaryTextTheme.button.color,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
