{ ... }:

{
  services.syncthing = {
    enable = true;

    settings = {
      devices = {
        pc.id = "SK3HCCN-ZXSDV3G-IPSDPSR-UP6PBVC-RZT4FMP-YNJZJEF-UDEZZJ4-A3ARHQ6";
        xmg.id = "V2MBCYZ-6HXPK3L-CELM2CO-CWLN4BQ-OZEPPF3-OUZYYHW-IC4SSBS-BXGOYQZ";
        dell.id = "3TPWPUA-QZHBKGH-VBB3KPR-AJOPAWO-LGXVKVX-P3YSWKI-XKNREPK-7VTCRQJ";
      };

      folders = {
        Music = {
          path = "/home/simon/Music";
          devices = [
            "pc"
            "xmg"
            "dell"
          ];
        };
        Documents = {
          path = "/home/simon/Documents";
          devices = [
            "pc"
            "dell"
          ];
        };
        Downloads = {
          path = "/home/simon/Downloads";
          devices = [
            "pc"
            "dell"
          ];
        };
      };
    };
  };
}
