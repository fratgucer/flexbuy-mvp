import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HTML = (ROOT / "index.html").read_text(encoding="utf-8")


class FlexBuySiteSmokeTests(unittest.TestCase):
    def test_mobile_media_queries_exist(self):
        self.assertIn("@media (max-width: 980px)", HTML)
        self.assertIn("@media (max-width: 640px)", HTML)
        self.assertIn(".sb{position:fixed", HTML)

    def test_mobile_sidebar_init_is_wired(self):
        self.assertIn("function initResponsiveChrome()", HTML)
        self.assertIn("loadPrefs();\ninitResponsiveChrome();", HTML)
        self.assertIn("window.addEventListener('resize', initResponsiveChrome);", HTML)

    def test_guest_defaults_do_not_fall_back_to_john_doe(self):
        self.assertIn("name: 'FlexBuy Guest'", HTML)
        self.assertNotIn("name: 'John Doe'", HTML)

    def test_password_strength_policy_is_enforced(self):
        self.assertRegex(HTML, r"pass\.length\s*>=\s*8")
        self.assertIn("/[a-z]/.test(pass)", HTML)
        self.assertIn("/[A-Z]/.test(pass)", HTML)
        self.assertIn("/\\d/.test(pass)", HTML)
        self.assertIn("/[^A-Za-z0-9]/.test(pass)", HTML)

    def test_profile_photo_controls_exist(self):
        for token in [
            "ep-avatar-input",
            "triggerProfilePhotoPicker()",
            "handleProfilePhotoSelect(event)",
            "renderEditProfileAvatarPreview()",
            "removeProfilePhoto()"
        ]:
            self.assertIn(token, HTML)

    def test_favicon_links_exist(self):
        self.assertIn('href="favicon.svg"', HTML)
        self.assertIn('rel="apple-touch-icon"', HTML)


if __name__ == "__main__":
    unittest.main()
