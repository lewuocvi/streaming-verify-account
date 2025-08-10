import { apiInitializer } from "discourse/lib/api";

let email = null;
let verify = null;

export async function getEmailFromBackend({ username }) {
  try {
    const response = await fetch(`https://emmcvietnam.com/u/${username}/emails.json`, { credentials: "include" });
    const jsonData = await response.json();
    email = jsonData.email || null;
  } catch (error) {
    console.error({ error: error.message, stack: error.stack });
  }
}

export default apiInitializer((api) => {
  const router = api.container.lookup("service:router");

  const currentUser = api.getCurrentUser();

  const hasTargetTag = () => {
    const routeName = router.currentRouteName ?? "";
    if (!routeName.startsWith("topic")) return false;

    const topicModel = api.container.lookup("controller:topic")?.model;
    if (!topicModel) return false;

    return (topicModel.tags || []).includes("easyjtag-plus");
  };

  const hideContent = () => {
    const mainOutlet = document.querySelector("#main");
    if (mainOutlet) mainOutlet.style.display = "none";
    document.body.style.overflow = "hidden";
  };

  const showContent = () => {
    const mainOutlet = document.querySelector("#main");
    if (mainOutlet) mainOutlet.style.display = "";
    document.body.style.overflow = "";
  };

  const showLoginAlert = async () => {
    const result = await Swal.fire({
      title: "Yêu cầu đăng nhập",
      text: "Bạn cần đăng nhập để xem bài viết này.",
      icon: "warning",
      confirmButtonText: "Tiếp tục",
      cancelButtonText: "Quay lại",
      showCancelButton: true,
      reverseButtons: true,
      allowOutsideClick: false,
      allowEscapeKey: false,
      customClass: {
        confirmButton: "btn btn-text btn-primary btn-small sign-up-button",
        cancelButton: "btn btn-text btn-danger btn-small",
      },
    });

    if (result.isConfirmed) {
      window.location.href = "/login";
    }
    //
    else if (result.isDismissed || result.dismiss === Swal.DismissReason.cancel) {
      showContent();
      window.history.back();
    }
  };

  const showNotification = async () => {
    const result = await Swal.fire({
      title: "Bạn phải mua gói dịch vụ trước để xem nọi dung.",
      text: "Phí duy trì dịch vụ 1200k mỗi năm. Vui lòng liên hệ quản trị viên qua Zalo 0979799247",
      icon: "error",
      width: 800,
      allowOutsideClick: false,
      allowEscapeKey: false,
      confirmButtonText: "Quay lại",
      customClass: {
        confirmButton: "btn btn-text btn-danger btn-small",
      },
      backdrop: `rgba(0,0,0,0.9)`,
    });

    if (result.isConfirmed) {
      window.location.href = "/";
    }
  };

  const checkSubscription = async ({ username }) => {
    try {
      if (!email) await getEmailFromBackend();

      const fetchSubscription = await fetch(`https://www-server.emmcvietnam.com/subscription/?email=${email}`);
      const { results } = await fetchSubscription.json();
      const stillValid = results.some(({ end_time }) => {
        return new Date(end_time).getTime() > Date.now();
      });

      verify = true;

      if (!stillValid) {
        await showNotification();
        return;
      }

      showContent();
    } catch (error) {
      console.error("Lỗi khi kiểm tra subscription:", error);
    }
  };

  const processPage = async () => {
    if (!hasTargetTag()) return;

    if (verify == true || verify == false) return;

    hideContent();

    if (!currentUser) {
      await showLoginAlert();
      return;
    }

    await checkSubscription(currentUser);
  };

  api.onAppEvent("page:loaded", processPage);
  api.onPageChange(processPage);
});
