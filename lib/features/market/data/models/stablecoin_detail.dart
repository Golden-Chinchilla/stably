import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/stablecoin_chain.dart';

class StablecoinDetail {
  const StablecoinDetail({required this.stablecoin, required this.chainData});

  final Stablecoin stablecoin;
  final List<StablecoinChain> chainData;

  factory StablecoinDetail.fromJson(Map<String, dynamic> json) {
    return StablecoinDetail(
      stablecoin: Stablecoin.fromJson(json),
      chainData: (json['chainData'] as List? ?? const [])
          .map(
            (item) => StablecoinChain.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}
