# screen.farm

Website: [https://screen.farm](https://screen.farm)

A tool to push content to any connected browser window.

You can use your tablet, phone or old laptop as a non-interactive external display
with minimal setup.

## Quick start

1.  Add your device to your "farm" by scanning the QR code or entering the URL on that device
2.  Your device will get a random name displayed in large letters, you can edit this
3.  A small tag will appear at the bottom for each connected screen, this is a bookmarklet, drag this to your bookmark bar
4.  Go to some webpage and press the bookmark – the webpage will now be opened on the respective device
5.  You can also use the REST API to a send a URL or image to a device.

## Uses

* while on a webpage, press a bookmarklet for your tablet and see the
  webpage open on your tablet
* take a screenshot and see it instantly appear on your tablet (see
  tools/screenshot-watcher.rb for OS X)

Using the REST API you can write any tool you can think of, some ideas:

* while coding, see the error messages with details
  instantly appear on your other device
* display the top article on Hacker News
* lolcats

## Warning

This project is in its initial dirty hack phase. Expect ugly code,
ridiculous bugs and security issues.

## License

MIT License

Copyright (c) 2015 Stimulus Software Limited

