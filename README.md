# gst-gdp-first-caps-problem-fix

Current implementation of gdp works only with synchronized producer-consumer.
You can't restart consumer without restarting producer. It is because gdp send
caps from producer to consumer before first buffer sending. If caps was not
send (or sent before consumer connected to producer) gdpdepay can't set caps
to consumer pipeline and throws error. But if we know the caps before starting
consumer and could set it to the gst pipeline, we can just ignoring first caps
problem.

## setup

0. install gstreamer

```bash
sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad
```

1. install gtk-doc

```bash
sudo apt-get install -y gtk-doc-tools
```

2. checkout gst-plugins-bad to your gstreamer version

```bash
cd gst-plugins-bad
git checkout $(gst-launch-1.0 --version | head -n 1 | awk '{print $3;}')
```

3. apply patch for [gdp](gst-plugins-bad/gst/gdp)

```bash
cd gst-plugins-bad/gst
patch -s -p0 < ../../gdp.patch
```

4. build gdp plugin

```bash
cd gst-plugins-bad
./autogen.sh
cd gst/gdp
make
```
