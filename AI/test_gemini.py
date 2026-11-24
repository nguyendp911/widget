import unittest
from unittest.mock import patch
import urllib.error
import gemini_provider as g

def model(name, methods=("generateContent",)):
    return {"name":"models/"+name,"supportedGenerationMethods":list(methods)}

class GeminiTests(unittest.TestCase):
    def setUp(self):
        g._cache = (0, [])
        g._bad.clear()
    def test_filter(self):
        self.assertTrue(g.is_text_model(model("gemini-99-flash")))
        self.assertFalse(g.is_text_model(model("gemini-99-flash-image")))
        self.assertFalse(g.is_text_model(model("gemini-99-live")))
        self.assertFalse(g.is_text_model(model("gemini-embedding-001",("embedContent",))))
    def test_rank(self):
        stable = model("gemini-4-flash")
        preview = model("gemini-5-flash-preview")
        pro = model("gemini-4-pro")
        self.assertGreater(g.rank(stable),g.rank(preview))
        self.assertGreater(g.rank(stable),g.rank(pro))
        self.assertGreater(g.rank(pro,"deep"),g.rank(stable,"deep"))
    @patch("gemini_provider.request")
    def test_pagination_and_cache(self, req):
        req.side_effect = [{"models":[model("gemini-4-flash")],"nextPageToken":"next"},
                           {"models":[model("gemini-4-pro"),model("gemini-4-live")]}]
        self.assertEqual(len(g.list_models()),2)
        self.assertEqual(len(g.list_models()),2)
        self.assertEqual(req.call_count,2)
    @patch("gemini_provider.list_models")
    @patch("gemini_provider.request")
    def test_fallback(self, req, models):
        models.return_value = [model("gemini-4-flash"),model("gemini-3-flash")]
        req.side_effect = [urllib.error.HTTPError("https://example.invalid",404,"missing",{},None),
                           {"candidates":[{"finishReason":"STOP","content":{"parts":[{"text":"Nội dung"}]}}]}]
        with patch.dict("os.environ",{"GEMINI_ALLOWED_MODELS":""}):
            result = g.generate("scope","calendar")
        self.assertEqual(result["model"],"gemini-3-flash")
        self.assertEqual(result["answer"],"Nội dung")
    @patch("gemini_provider.list_models")
    @patch("gemini_provider.request")
    def test_quota_no_retry(self,req,models):
        models.return_value = [model("gemini-4-flash"),model("gemini-3-flash")]
        req.side_effect = urllib.error.HTTPError("https://example.invalid",429,"quota",{},None)
        with patch.dict("os.environ",{"GEMINI_ALLOWED_MODELS":""}):
            with self.assertRaises(urllib.error.HTTPError):
                g.generate("scope","calendar")
        self.assertEqual(req.call_count,1)

if __name__ == "__main__":
    unittest.main()
