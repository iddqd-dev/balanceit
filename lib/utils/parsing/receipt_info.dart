abstract class QRCodeChecker {
  bool isFiscal(String code);
}

class ReceiptInfo{
  final String timestamp;
  final String sum;
  final String fiscalNumber;
  final String documentNumber;
  final String fiscalDocumentIdentifier;
  final String fiscalSign;
  final String operationType;

  ReceiptInfo({
    required this.timestamp,
    required this.sum,
    required this.fiscalNumber,
    required this.documentNumber,
    required this.fiscalDocumentIdentifier,
    required this.fiscalSign,
    required this.operationType,
  });

  factory ReceiptInfo.fromString(String code) {
    final queryParams = code.split('&');
    final timestamp = queryParams[0].substring(2);
    final sum = queryParams[1].substring(2).replaceFirst('.', '');
    final fiscalNumber = queryParams[2].substring(3);
    final documentNumber = queryParams[3].substring(2);
    final fiscalDocumentIdentifier = queryParams[4].substring(3);
    final fiscalSign = queryParams[5].substring(3);
    final operationType = queryParams.length > 6 ? queryParams[6].substring(2) : '';
    return ReceiptInfo(
      timestamp: timestamp,
      sum: sum,
      fiscalNumber: fiscalNumber,
      documentNumber: documentNumber,
      fiscalDocumentIdentifier: fiscalDocumentIdentifier,
      fiscalSign: fiscalSign,
      operationType: operationType,
    );
  }

  @override
  String toString() {
    return 'ReceiptInfo { timestamp: $timestamp, sum: $sum, fiscalNumber: $fiscalNumber, documentNumber: $documentNumber, fiscalDocumentIdentifier: $fiscalDocumentIdentifier, fiscalSign: $fiscalSign, operationType: $operationType }';
  }

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'sum': sum,
    'fiscalNumber': fiscalNumber,
    'documentNumber': documentNumber,
    'fiscalDocumentIdentifier': fiscalDocumentIdentifier,
    'fiscalSign': fiscalSign,
    'operationType': operationType,
  };

  String getSumInRubles() {
    final rubles = int.parse(sum) ~/ 100;
    final kopecks = int.parse(sum) % 100;
    return '$rubles,$kopecks руб.';
  }


}

class FiscalQRCodeChecker implements QRCodeChecker {
  @override
  bool isFiscal(String code) {
    final queryParams = code.split('&');
    return queryParams.length >= 6 && queryParams[2].startsWith('fn=');
  }
}