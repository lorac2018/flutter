import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:barcode_scan/barcode_scan.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _brandFocusNode = FocusNode();
  final _quantityFocusNode = FocusNode();
  final _validationDateFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  DateTime _selectedDate;
  String _displayDate;
  final DateTime _currentDate = DateTime.now();
  var _difference;
  String _barcode;

  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    brand: '',
    quantity: 0,
    date: null,
    imageUrl: '',
    barcode: '',
  );
  var _initValues = {
    'title': '',
    'brand': '',
    'price': '',
    'quantity': '',
    'date': '',
    'imageUrl': '',
    'barcode': '',
  };
  var _isInit = true;
  var _isLoading = false;

  _EditProductScreenState();

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'brand': _editedProduct.brand,
          'price': _editedProduct.price.toString(),
          'quantity': _editedProduct.quantity.toString(),
          'date': _editedProduct.date.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
          'barcode': _editedProduct.barcode.toString(),
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _brandFocusNode.dispose();
    _quantityFocusNode.dispose();
    _validationDateFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
          !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  DateTime _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2019),
      lastDate: DateTime(2030),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
        _difference = "${pickedDate.difference(_currentDate).inDays}";
        print(_difference);
      });
    });
  }
  Future _scan() async {
    try {
      String code = await BarcodeScanner.scan();
      setState(() => _barcode = code);
      print(this._barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => _barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => _barcode =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => _barcode = 'Unknown error: $e');
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              //Title
              TextFormField(
                initialValue: _initValues['title'],
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide the name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: value,
                    price: _editedProduct.price,
                    brand: _editedProduct.brand,
                    quantity: _editedProduct.quantity,
                    date: _editedProduct.date,
                    numberofdays: _editedProduct.numberofdays,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _editedProduct.barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              //Price
              TextFormField(
                initialValue: _initValues['price'],
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_brandFocusNode);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide the price.';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a number greater than zero.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: double.parse(value),
                    brand: _editedProduct.brand,
                    quantity: _editedProduct.quantity,
                    date: _editedProduct.date,
                    numberofdays: _editedProduct.numberofdays,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _editedProduct.barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              //Brand
              TextFormField(
                initialValue: _initValues['brand'],
                decoration: InputDecoration(labelText: 'Brand'),
                keyboardType: TextInputType.multiline,
                focusNode: _brandFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please provide the brand.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    brand: value,
                    quantity: _editedProduct.quantity,
                    date: _editedProduct.date,
                    numberofdays: _editedProduct.numberofdays,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _editedProduct.barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              //Quantity
              TextFormField(
                initialValue: _initValues['quantity'],
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.multiline,
                focusNode: _quantityFocusNode,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the quantity.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    brand: _editedProduct.brand,
                    quantity: int.parse(value),
                    date: _editedProduct.date,
                    numberofdays: _editedProduct.numberofdays,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _editedProduct.barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              //Date
              Container(
                height: 70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date entered!'
                            : 'Picked Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      ),
                    ),
                    FlatButton(
                      child: Text('Enter the Validation Date',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        _presentDatePicker();
                      },
                    ),
                  ],
                ),
              ),
              TextFormField(
                onSaved: (value) {
                  _displayDate =
                      DateFormat('yyyy-MM-dd').format(_selectedDate);
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    brand: _editedProduct.brand,
                    quantity: _editedProduct.quantity,
                    date: _displayDate,
                    numberofdays: _difference,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _editedProduct.barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                  );
                },
              ),
              RaisedButton(
                child: Text('Scan the barcode'),
                onPressed: () => {
                  _scan(),
                  print(_barcode),
                },
              ),
              TextFormField(
                onSaved: (value) {
                  _editedProduct = Product(
                    title: _editedProduct.title,
                    price: _editedProduct.price,
                    brand: _editedProduct.brand,
                    quantity: _editedProduct.quantity,
                    date: _editedProduct.date,
                    numberofdays: _editedProduct.numberofdays,
                    imageUrl: _editedProduct.imageUrl,
                    barcode: _barcode,
                    id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,

                  );
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: _imageUrlController.text.isEmpty
                        ? Text('Enter a URL')
                        : FittedBox(
                      child: Image.network(
                        _imageUrlController.text,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Image URL'),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an image URL.';
                        }
                        if (!value.startsWith('http') &&
                            !value.startsWith('https')) {
                          return 'Please enter a valid URL.';
                        }
                        if (!value.endsWith('.png') &&
                            !value.endsWith('.jpg') &&
                            !value.endsWith('.jpeg')) {
                          return 'Please enter a valid image URL.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          brand: _editedProduct.brand,
                          quantity: _editedProduct.quantity,
                          date: _editedProduct.date,
                          numberofdays: _editedProduct.numberofdays,
                          imageUrl: value,
                          barcode: _editedProduct.barcode,
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
