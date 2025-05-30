if [ -x "/usr/bin/hpffutil" ] || [ -x "/bin/hpffutil" ] || [ -x "/usr/local/bin/hpffutil" ]; then
  echo "hpffutil found"
else
  echo "hpffutil not found, install it from https://github.com/quantumde/hpff"
fi

printf "Packing assets...\n"

hpffutil pack res/bg.bin res/backgrounds/*
hpffutil pack res/tex.bin res/tex/*
hpffutil pack res/enemies.bin res/enemies/*
hpffutil pack res/faces.bin res/faces/*
hpffutil pack res/data.bin res/data/*