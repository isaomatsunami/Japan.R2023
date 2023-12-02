functions {
  // 順位が観測される対数尤度を返す関数
  real rank_logit_lpmf(array[] int rank_order, vector delta) {
    vector[rows(delta)] tmp = delta[rank_order];
    real out;
    for(i in 1:(rows(tmp) - 1)) {
      if(i == 1) {
        out = tmp[1] - log_sum_exp(tmp);
      } else {
        out += tmp[i] - log_sum_exp(tmp[i:]);
      }
    }
    return(out);
  }
}
data {
  int nRacer;
  int nRace;
  int nRow;
  array[nRow] int race_order;
  array[nRow] int racer_index;
  array[nRow] int lane_index;   // 追加
  array[nRace] int start_index;
  array[nRace] int end_index;
  array[nRace] int race_size;
}
parameters {
  vector[nRacer] racers;
  vector[6] waku_coefs;   // 追加
  vector[nRow] mu;
  real<lower = 1.0> sigma;
}
model {
  racers ~ normal(0.0, 100.0);
  mu ~ normal(0.0, sigma);
  for(r in 1:nRace) {
    vector[race_size[r]] utilities;  // 商品選択の潜在変数(utility)が起源
    utilities = racers[ racer_index[start_index[r]:end_index[r]] ] +
                waku_coefs[ lane_index[start_index[r]:end_index[r]] ] + // 追加
                mu[start_index[r]:end_index[r]];
    race_order[start_index[r]:end_index[r]] ~ rank_logit(utilities);
  }
}