import { useState } from 'react';

export function useListPaging(pageSize: number) {
  const [page, setPage] = useState(1);

  const doiBoLoc = (thayDoi: () => void) => {
    thayDoi();
    setPage(1);
  };

  const phanTrang = (total: number | undefined) => ({
    page,
    pageSize,
    total: total ?? 0,
    onPageChange: setPage,
  });

  return { page, setPage, doiBoLoc, phanTrang };
}
