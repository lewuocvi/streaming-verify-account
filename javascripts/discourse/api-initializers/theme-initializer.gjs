import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  const currentUser = api.getCurrentUser();

  console.log({ currentUser });

  const hasTargetTag = () => {
    const routeName = router.currentRouteName ?? "";
    if (!routeName.startsWith("topic")) return false;

    const topicModel = api.container.lookup("controller:topic")?.model;
    if (!topicModel) return false;

    console.log(topicModel.tags);

    for (const keywork of ["jtag", "ufi", "medusa", "f64", "mod-rom", "emmc", "ufs"]) {
      for (const element of topicModel.tags || []) {
        console.log({ element });
        if (element.includes(keywork)) {
          return element;
        }
      }
    }

    return false;
  };

  api.decorateCooked(($elem, helper) => {
    // 🔒 Kiểm tra quyền (ví dụ: nếu user chưa đăng nhập hoặc không phải staff)
    const noAccess = !hasTargetTag();
    if (noAccess) {
      // Xoá nội dung cũ
      $elem.empty();

      // Thêm thông báo cảnh báo
      $elem.append(`
        <div class="no-access-warning" style="padding: 1em; background: #fff3cd; border: 1px solid #ffeeba; border-radius: 6px; color: #856404;">
          ⚠️ Bạn không có quyền xem nội dung của bài viết này.
        </div>
      `);
    }
  });

  // api.onAppEvent("page:loaded", processPage);
  // api.onPageChange(processPage);
});
