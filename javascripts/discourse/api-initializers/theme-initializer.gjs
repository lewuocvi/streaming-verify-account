import { apiInitializer } from "discourse/lib/api";

export default apiInitializer("1.19.0", (api) => {
  const router = api.container.lookup("service:router");

  const hasTargetTag = () => {
    const routeName = router.currentRouteName ?? "";
    if (!routeName.startsWith("topic")) return false;

    const topicModel = api.container.lookup("controller:topic")?.model;
    if (!topicModel || !Array.isArray(topicModel.tags)) return false;

    const targetTags = ["jtag", "ufi", "medusa", "f64", "mod-rom", "emmc", "ufs"];

    return topicModel.tags.some((tag) => targetTags.some((keyword) => tag.toLowerCase().includes(keyword)));
  };

  api.decorateCooked(($elem, helper) => {
    const currentUser = api.getCurrentUser();

    const userIsVerified = currentUser?.title?.startsWith("Verified");
    const topicHasTargetTag = hasTargetTag();

    // Nếu user không verified và topic có tag cần khoá → chặn
    if (!userIsVerified && topicHasTargetTag) {
      $elem.empty();

      $elem.append(`
        <div class="no-access-warning" style="
          padding: 1em;
          background: #fff3cd;
          border: 1px solid #ffeeba;
          border-radius: 6px;
          color: #856404;
        ">
          ⚠️ Bạn không có quyền xem nội dung của bài viết này.
        </div>
      `);
    }
  });
});
