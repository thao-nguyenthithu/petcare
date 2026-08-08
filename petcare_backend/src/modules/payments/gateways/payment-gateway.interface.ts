
export type PhienTraTien = {
  payUrl: string;
};

export type KetQuaCong = {
  txnRef: string;
  thanhCong: boolean;
  soTien: number;
  maGiaoDich: string | null;
  ngayTraCong: string | null;
  bankCode: string | null;
  cardType: string | null;
  maPhanHoi: string | null;
  duLieuGoc: Record<string, string>;
};

export interface PaymentGateway {
  readonly ten: string;

  readonly tuDongChot?: boolean;

  taoPhien(p: {
    txnRef: string;
    soTien: number;
    moTa: string;
    ip: string;
    hetHan: Date;
  }): PhienTraTien;

  docKetQua(query: Record<string, string>): KetQuaCong;
}
