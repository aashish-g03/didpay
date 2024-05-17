import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/shared/http_status.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

final tbdexServiceProvider = Provider((_) => TbdexService());

class TbdexService {
  Future<List<Offering>> getOfferings(List<Pfi> pfis) async {
    final offerings = <Offering>[];

    for (final pfi in pfis) {
      final response = await TbdexHttpClient.listOfferings(pfi.did);
      if (response.statusCode.category == HttpStatus.success) {
        offerings.addAll(response.data!);
      }
    }

    if (offerings.isEmpty) {
      throw Exception('no offerings found');
    }

    return offerings;
  }

  Future<Map<Pfi, List<String>>> getExchanges(
    BearerDid did,
    List<Pfi> pfis,
  ) async {
    final exchangesMap = <Pfi, List<String>>{};

    for (final pfi in pfis) {
      final response = await TbdexHttpClient.listExchanges(did, pfi.did);
      if (response.statusCode.category == HttpStatus.success) {
        exchangesMap[pfi] = response.data!;
      }
    }

    if (exchangesMap.isEmpty) {
      throw Exception('no exchanges found');
    }

    return exchangesMap;
  }

  Future<List<Message>> getExchange(
    BearerDid did,
    Pfi pfi,
    String exchangeId,
  ) async {
    final response =
        await TbdexHttpClient.getExchange(did, pfi.did, exchangeId);
    if (response.statusCode.category == HttpStatus.success) {
      return response.data!;
    }

    throw Exception(
      'failed to fetch exchange with status code ${response.statusCode}',
    );
  }

  Future<Rfq> sendRfq(BearerDid did, Pfi pfi, RfqState rfqState) async {
    final rfq = Rfq.create(
      pfi.did,
      did.uri,
      CreateRfqData(
        offeringId: rfqState.offering?.metadata.id ?? '',
        payin: CreateSelectedPayinMethod(
          amount: rfqState.payinAmount ?? '',
          kind: rfqState.payinMethod?.kind ?? '',
        ),
        payout: CreateSelectedPayoutMethod(
          kind: rfqState.payoutMethod?.kind ?? '',
        ),
        claims: [],
      ),
    );
    await rfq.sign(did);

    final response =
        await TbdexHttpClient.createExchange(rfq, replyTo: rfq.metadata.from);

    if (response.statusCode.category != HttpStatus.success) {
      throw Exception(
        'failed to send rfq with status code ${response.statusCode}',
      );
    }
    return rfq;
  }

  // TODO(ethan-tbd): create order, https://github.com/TBD54566975/didpay/issues/115
}