---
layout: post
title:  "Soma de gastos por partidos"
date:   2014-05-19 16:39
poster: abel
categories: gastos partido
---

A imagem a seguir mostra a quantidade de dinheiro gasto pelos deputados somados
por partido no momento da eleição, e escalados pela quantidade de pessoas no
partido.
<canvas id="myChart" width="600" height="500"></canvas>

<script src="{{ site.baseurl }}/assets/soma-de-gastos-partidos.js">
</script>
<script>
options = {
  xAxisLabel : "Gasto acumulado pos partido, escalado pelo número de pessoas (em Milhões).",
  xAxisFontSize: 12,
  barStrokeWidth: 1,
  barValueSpacing: 14,
  animation : true
}
new Chart(document.getElementById("myChart").getContext("2d")).HorizontalBar(data,options);
</script>
