// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<XFile>? _imageFileList;

  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  VideoPlayerController? _controller;
  VideoPlayerController? _toBeDisposed;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

  Future<void> _playVideo(XFile? file) async {
    if (file != null && mounted) {
      await _disposeVideoController();
      late VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.network(file.path);
      } else {
        controller = VideoPlayerController.file(File(file.path));
      }
      _controller = controller;
      // In web, most browsers won't honor a programmatic call to .play
      // if the video has a sound track (and is not muted).
      // Mute the video so it auto-plays in web!
      // This is not needed if the call to .play is the result of user
      // interaction (clicking on a "play" button, for example).
      const double volume = kIsWeb ? 0.0 : 1.0;
      await controller.setVolume(volume);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      setState(() {});
    }
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    if (_controller != null) {
      await _controller!.setVolume(0.0);
    }
    if (isVideo) {
      final XFile? file = await _picker.pickVideo(
          source: source, maxDuration: const Duration(seconds: 10));
      await _playVideo(file);
    } else if (isMultiImage) {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final List<XFile> pickedFileList = await _picker.pickMultiImage(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _imageFileList = pickedFileList;
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    } else {
      await _displayPickImageDialog(context!,
          (double? maxWidth, double? maxHeight, int? quality) async {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _setImageFileListFromFile(pickedFile);
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void deactivate() {
    if (_controller != null) {
      _controller!.setVolume(0.0);
      _controller!.pause();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    _disposeVideoController();
    maxWidthController.dispose();
    maxHeightController.dispose();
    qualityController.dispose();
    super.dispose();
  }

  Future<void> _disposeVideoController() async {
    if (_toBeDisposed != null) {
      await _toBeDisposed!.dispose();
    }
    _toBeDisposed = _controller;
    _controller = null;
  }

  Widget _previewVideo() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_controller == null) {
      return const Text(
        'You have not yet picked a video',
        textAlign: TextAlign.center,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: AspectRatioVideo(_controller),
    );
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return Semantics(
        label: 'image_picker_example_picked_images',
        child: ListView.builder(
          key: UniqueKey(),
          itemBuilder: (BuildContext context, int index) {
            // Why network for web?
            // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
            return Semantics(
              label: 'image_picker_example_picked_image',
              child: kIsWeb
                  ? Image.network(_imageFileList![index].path)
                  : Image.file(File(_imageFileList![index].path)),
            );
          },
          itemCount: _imageFileList!.length,
        ),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Widget _handlePreview() {
    if (isVideo) {
      return _previewVideo();
    } else {
      return _previewImages();
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      if (response.type == RetrieveType.video) {
        isVideo = true;
        await _playVideo(response.file);
      } else {
        isVideo = false;
        setState(() {
          if (response.files == null) {
            _setImageFileListFromFile(response.file);
          } else {
            _imageFileList = response.files;
          }
        });
      }
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  // String imageUrl =
  //     'https://closer-media.s3.eu-west-1.amazonaws.com/1/1/1673782139.jpg?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEKr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiBiZlg2zVpLQXK5ZOhty6eHQ83THEYuBe73XyN78SsTOAIhAIV9SLfesu%2FyZ8Anga6uv18Y%2FpNRJWElysbqws%2FKWMuLKuQCCBMQABoMMTEzNDg3MDc1MzY0IgyBdfUc3lZy3lvq2a8qwQKRSgWbQyySlXg%2FQBmdx8A08zk5Il%2FKg%2FJ8xbrfa138SKrXgP4ML6XuzTj166WJc9ERELotgG%2Fo8ZHdKyOf5Wr3k5U59q7yS572BJxvyXWXvqEtkpi1IRpraVQxDrzBWcy8zgAh2TeiWj61RABk%2Fbv4NVguExwEJqlFpAl0pABdPcHO%2BIc0nRmteknW40hywKBHh0G0z3Yg9JG4gURGmPuE4zzHgXNwEJub46uaTzS9Vnj0%2BAUzuKQbNVySwer09RO2paEcBuKT5RuZA1j7X8X1SE1peeZPm%2FfNJGp4baXsgaKrN27Lg18Yxj6FNAB6xqVHtQ%2Bw%2FcRqud5TcMtLR6KffHEnZx0ZlFMMAMr5%2BiMhYEZqSRqA3rzp9%2B0LhPuBhB2XwG7mGCO%2FRYXFnH2xvIRJl8txzrAB28%2Bjr%2BcAQIhAx0Iwo6GPngY6swJg5wAebnCgkE%2FhgmO6c0Cr0UqX9J8PyLmYEqrfMKlrDryxy5kZtmX1fBpyNXxlT9CYPCzy7qskkgjfhstEs5sUAzPv5gZba6DJHduB2WGsWq0%2F3mKIKZ%2BjgyYph9eqyp7%2BSgIUlstRTvWF6dOPXF0EWMyv7hsFZOqliI5gxh5AobPOf7DuHefiEtpbxFBEJk6mnJdQSdbkAAyOPbyExGg2HHnJ%2BaHyLn889qx84AXicHH%2BSqakCuNJz%2F%2BwkZJhwu56bh7dwG4NtdqDis5MuSnK6hL%2FvLBZ%2FwdiWMYIcDHrZlIN4lP2H8S4kdzhxda6BWTtjf3rTQs8PPMhzwc8B%2Bt2qA7IhVlEY0X2tc39RCvTZX67AANjuGHxFqVabDqTrytJ%2FUF5Ob1Q55SCBm%2Fnhx1r5hi5&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230115T112918Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43199&X-Amz-Credential=ASIARU3C3LASOUO2C5UG%2F20230115%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Signature=50d870911e8ea8c4b79ad288c1feb363c3c6eff9ba9da48cc6f77b667b67f830';
  // String imageUrl =
  //     'https://closer-media.s3.eu-west-1.amazonaws.com/1/1/1673784410.png?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEKr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiBiZlg2zVpLQXK5ZOhty6eHQ83THEYuBe73XyN78SsTOAIhAIV9SLfesu%2FyZ8Anga6uv18Y%2FpNRJWElysbqws%2FKWMuLKuQCCBMQABoMMTEzNDg3MDc1MzY0IgyBdfUc3lZy3lvq2a8qwQKRSgWbQyySlXg%2FQBmdx8A08zk5Il%2FKg%2FJ8xbrfa138SKrXgP4ML6XuzTj166WJc9ERELotgG%2Fo8ZHdKyOf5Wr3k5U59q7yS572BJxvyXWXvqEtkpi1IRpraVQxDrzBWcy8zgAh2TeiWj61RABk%2Fbv4NVguExwEJqlFpAl0pABdPcHO%2BIc0nRmteknW40hywKBHh0G0z3Yg9JG4gURGmPuE4zzHgXNwEJub46uaTzS9Vnj0%2BAUzuKQbNVySwer09RO2paEcBuKT5RuZA1j7X8X1SE1peeZPm%2FfNJGp4baXsgaKrN27Lg18Yxj6FNAB6xqVHtQ%2Bw%2FcRqud5TcMtLR6KffHEnZx0ZlFMMAMr5%2BiMhYEZqSRqA3rzp9%2B0LhPuBhB2XwG7mGCO%2FRYXFnH2xvIRJl8txzrAB28%2Bjr%2BcAQIhAx0Iwo6GPngY6swJg5wAebnCgkE%2FhgmO6c0Cr0UqX9J8PyLmYEqrfMKlrDryxy5kZtmX1fBpyNXxlT9CYPCzy7qskkgjfhstEs5sUAzPv5gZba6DJHduB2WGsWq0%2F3mKIKZ%2BjgyYph9eqyp7%2BSgIUlstRTvWF6dOPXF0EWMyv7hsFZOqliI5gxh5AobPOf7DuHefiEtpbxFBEJk6mnJdQSdbkAAyOPbyExGg2HHnJ%2BaHyLn889qx84AXicHH%2BSqakCuNJz%2F%2BwkZJhwu56bh7dwG4NtdqDis5MuSnK6hL%2FvLBZ%2FwdiWMYIcDHrZlIN4lP2H8S4kdzhxda6BWTtjf3rTQs8PPMhzwc8B%2Bt2qA7IhVlEY0X2tc39RCvTZX67AANjuGHxFqVabDqTrytJ%2FUF5Ob1Q55SCBm%2Fnhx1r5hi5&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230115T120757Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIARU3C3LASOUO2C5UG%2F20230115%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Signature=d7f8edfe690a9879ea4ee10609974f9b36752aa92df762723c3936e48d730f2d';
  String imageUrl =
      'https://closer-media.s3.eu-west-1.amazonaws.com/1/1/resized-1673802765.jpg?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEKr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiBiZlg2zVpLQXK5ZOhty6eHQ83THEYuBe73XyN78SsTOAIhAIV9SLfesu%2FyZ8Anga6uv18Y%2FpNRJWElysbqws%2FKWMuLKuQCCBMQABoMMTEzNDg3MDc1MzY0IgyBdfUc3lZy3lvq2a8qwQKRSgWbQyySlXg%2FQBmdx8A08zk5Il%2FKg%2FJ8xbrfa138SKrXgP4ML6XuzTj166WJc9ERELotgG%2Fo8ZHdKyOf5Wr3k5U59q7yS572BJxvyXWXvqEtkpi1IRpraVQxDrzBWcy8zgAh2TeiWj61RABk%2Fbv4NVguExwEJqlFpAl0pABdPcHO%2BIc0nRmteknW40hywKBHh0G0z3Yg9JG4gURGmPuE4zzHgXNwEJub46uaTzS9Vnj0%2BAUzuKQbNVySwer09RO2paEcBuKT5RuZA1j7X8X1SE1peeZPm%2FfNJGp4baXsgaKrN27Lg18Yxj6FNAB6xqVHtQ%2Bw%2FcRqud5TcMtLR6KffHEnZx0ZlFMMAMr5%2BiMhYEZqSRqA3rzp9%2B0LhPuBhB2XwG7mGCO%2FRYXFnH2xvIRJl8txzrAB28%2Bjr%2BcAQIhAx0Iwo6GPngY6swJg5wAebnCgkE%2FhgmO6c0Cr0UqX9J8PyLmYEqrfMKlrDryxy5kZtmX1fBpyNXxlT9CYPCzy7qskkgjfhstEs5sUAzPv5gZba6DJHduB2WGsWq0%2F3mKIKZ%2BjgyYph9eqyp7%2BSgIUlstRTvWF6dOPXF0EWMyv7hsFZOqliI5gxh5AobPOf7DuHefiEtpbxFBEJk6mnJdQSdbkAAyOPbyExGg2HHnJ%2BaHyLn889qx84AXicHH%2BSqakCuNJz%2F%2BwkZJhwu56bh7dwG4NtdqDis5MuSnK6hL%2FvLBZ%2FwdiWMYIcDHrZlIN4lP2H8S4kdzhxda6BWTtjf3rTQs8PPMhzwc8B%2Bt2qA7IhVlEY0X2tc39RCvTZX67AANjuGHxFqVabDqTrytJ%2FUF5Ob1Q55SCBm%2Fnhx1r5hi5&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230115T171429Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIARU3C3LASOUO2C5UG%2F20230115%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Signature=a671d8b0deed5a1ac5d89ae487268aae42105d8442921f6c92a55066f02ba73a';
  String imageBase64 = '/9j/4AAQSkZJRgABAQEAYABgAAD//gA+Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcgSlBFRyB2NjIpLCBkZWZhdWx0IHF1YWxpdHkK/9sAQwAIBgYHBgUIBwcHCQkICgwUDQwLCwwZEhMPFB0aHx4dGhwcICQuJyAiLCMcHCg3KSwwMTQ0NB8nOT04MjwuMzQy/9sAQwEJCQkMCwwYDQ0YMiEcITIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIy/8AAEQgAlgBkAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwDAQACEQMRAD8A8P7U2n9qZQA8dKB9403fjgg0BxvPNADz0poHHFLkEUL92gBOc0MeKX+KkfpTAO1IAD1p3amjrSATZg8GjnOCKfnmj1oAbiiiigB3amU+m0AOHSm4Bc5FKCPWkH3z9KAAoPpSKDjhqfSL0pgNywbsaVjxyKX+IUN0oEL2po607tTMZIpDH96KTBz1o55oASiiigB1Np1NoAaYgxzmk8nHRqkFLTuKxF5b9moCyDuKloouFiL94DnApSzHGRUlI3Si4C9qZkKQTT+1IKQxN6k9aXcDnmlwPQUm0DtQAUUUUAL2ptO7U2gAzzQTSgUbRTEM3GlDUu0UuBQA0MTSmlwKG6UAL2ptO7UgpDAmgdKKXtTEJRRRSGL2ptO7UlABS0UYoAMUUUUAFI3SgsO3Wms4xjvQJiuSF4pqNzg96cx+WogM0mBOSPWk3DpmgItLgDoKYxKKKKAF7UlLnim5NAAXVeDTfNz0UmlOB25NPFFwsR5kPQAU1w/97JqY0zAySOtFwsNHA96jaUq4x+NShSRmq0ilX5pK9x6WLWSR7GhV55FC42A+1KpHrRYB22kwfWnUHpTENzRTaKAFLAGjcPWkK5OaNtTqPQB8zVJTVGKWmkJgaaFANPpKYCUwoC2aeaKAEIwuKiCE96lPNAAHSiwJjFjYH75qTt1opKAGnrRS4opgLikxTqM0gAClptGaAHZpKSigBaSiigAopKUCgBcUUUUAJRRRQAlFJmimIWikpaAClpKUCgYlLilopAJRRRQAZoopKACiiigBtFFFMQtFFFADgMUtFFIYmaKKKAEooooAKKKKADNFFFAH/9k=';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Column(
        children: [
          Spacer(),
          // Image.network(
          //   width: 200,
          //   height: 200,
          //     fit: BoxFit.fill,
          //     'https://closer-media.s3.eu-west-1.amazonaws.com/1673781409.jpg?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEKr%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiBiZlg2zVpLQXK5ZOhty6eHQ83THEYuBe73XyN78SsTOAIhAIV9SLfesu%2FyZ8Anga6uv18Y%2FpNRJWElysbqws%2FKWMuLKuQCCBMQABoMMTEzNDg3MDc1MzY0IgyBdfUc3lZy3lvq2a8qwQKRSgWbQyySlXg%2FQBmdx8A08zk5Il%2FKg%2FJ8xbrfa138SKrXgP4ML6XuzTj166WJc9ERELotgG%2Fo8ZHdKyOf5Wr3k5U59q7yS572BJxvyXWXvqEtkpi1IRpraVQxDrzBWcy8zgAh2TeiWj61RABk%2Fbv4NVguExwEJqlFpAl0pABdPcHO%2BIc0nRmteknW40hywKBHh0G0z3Yg9JG4gURGmPuE4zzHgXNwEJub46uaTzS9Vnj0%2BAUzuKQbNVySwer09RO2paEcBuKT5RuZA1j7X8X1SE1peeZPm%2FfNJGp4baXsgaKrN27Lg18Yxj6FNAB6xqVHtQ%2Bw%2FcRqud5TcMtLR6KffHEnZx0ZlFMMAMr5%2BiMhYEZqSRqA3rzp9%2B0LhPuBhB2XwG7mGCO%2FRYXFnH2xvIRJl8txzrAB28%2Bjr%2BcAQIhAx0Iwo6GPngY6swJg5wAebnCgkE%2FhgmO6c0Cr0UqX9J8PyLmYEqrfMKlrDryxy5kZtmX1fBpyNXxlT9CYPCzy7qskkgjfhstEs5sUAzPv5gZba6DJHduB2WGsWq0%2F3mKIKZ%2BjgyYph9eqyp7%2BSgIUlstRTvWF6dOPXF0EWMyv7hsFZOqliI5gxh5AobPOf7DuHefiEtpbxFBEJk6mnJdQSdbkAAyOPbyExGg2HHnJ%2BaHyLn889qx84AXicHH%2BSqakCuNJz%2F%2BwkZJhwu56bh7dwG4NtdqDis5MuSnK6hL%2FvLBZ%2FwdiWMYIcDHrZlIN4lP2H8S4kdzhxda6BWTtjf3rTQs8PPMhzwc8B%2Bt2qA7IhVlEY0X2tc39RCvTZX67AANjuGHxFqVabDqTrytJ%2FUF5Ob1Q55SCBm%2Fnhx1r5hi5&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230115T112051Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIARU3C3LASOUO2C5UG%2F20230115%2Feu-west-1%2Fs3%2Faws4_request&X-Amz-Signature=a94cb885d316aceb669ba7d7289a03d244c9ed3ca3fe7e7ca00efd3a7ee7e635'),
          Align(
            alignment: Alignment.bottomRight,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ImageDialog(imageBase64)),
                );
              },
              child: Container(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ConstrainedBox(
                    constraints: new BoxConstraints(
                      minWidth: 150,
                      maxWidth: 250,
                      minHeight: 150,
                      maxHeight: 250
                    ),
                    child: Image.memory(
                      fit: BoxFit.fitWidth,
                      Base64Codec().decode(imageBase64),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxWidth if desired'),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxHeight if desired'),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter quality if desired'),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    final double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    final int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {Key? key}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}

class ImageDialog extends StatelessWidget {
  final String imageBlob;

  ImageDialog(this.imageBlob);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('image'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Image.memory(
            Base64Codec().decode(imageBlob),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
