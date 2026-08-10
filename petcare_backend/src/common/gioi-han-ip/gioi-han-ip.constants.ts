// Trần yêu cầu theo IP trong cửa sổ một phút (bộ luật mục 12)
export const CUA_SO_IP_MS = 60 * 1000;
export const TRAN_IP_MOI_PHUT = 300;
export const TRAN_XAC_THUC_MOI_PHUT = 20;

// Gắn cho nhóm xác thực và kiểm tra số căn cước qua @Throttle
export const THROTTLE_XAC_THUC = {
  default: { limit: TRAN_XAC_THUC_MOI_PHUT, ttl: CUA_SO_IP_MS },
};
